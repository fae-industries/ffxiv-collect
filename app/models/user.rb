# == Schema Information
#
# Table name: users
#
#  id                  :bigint           not null, primary key
#  admin               :boolean          default(FALSE)
#  avatar_url          :string(255)
#  database            :string(255)      default("garland"), not null
#  discriminator       :integer
#  mod                 :boolean          default(FALSE)
#  provider            :string(255)
#  uid                 :string(255)
#  username            :string(255)
#  zen                 :boolean          default(FALSE)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  character_id        :integer
#  current_identity_id :integer
#

class User < ApplicationRecord
  belongs_to :character, required: false
  belongs_to :current_identity, class_name: 'Identity', foreign_key: :current_identity_id, required: false

  has_many :decks, primary_key: :uid, foreign_key: :user_uid
  has_many :identities
  has_many :modifications, class_name: 'PaperTrail::Version', foreign_key: :whodunnit
  has_many :owned_groups, class_name: 'Group', foreign_key: :owner_id
  has_many :user_characters
  has_many :votes

  has_many :characters, through: :user_characters
  has_many :verified_characters, -> (user) { where(verified_user: user) }, through: :user_characters, source: :character

  delegate :avatar_url, to: :current_identity, allow_nil: true
  delegate :username, to: :current_identity, allow_nil: true

  devise :omniauthable, :timeoutable, omniauth_providers: %i(discord google_oauth2 xivauth)

  def self.from_omniauth(auth, current_user = nil)
    # Clean up any special characters in the username
    username = auth.info.name.encode(Encoding.find('ASCII'), invalid: :replace, undef: :replace, replace: '')
    email = auth.info.email

    # The key to looking up the identity
    key_fields = { provider: auth.provider, uid: auth.uid }

    # Attributes that can change between logins and should be updated
    attributes = {
      username: auth.provider == 'google_oauth2' ? email : username,
      avatar_url: auth.info.image,
    }

    identity = Identity.find_by(key_fields)

    if identity.present?
      # If a user connects an existing identity, move it to them
      attributes.merge!(user_id: current_user.id) if current_user.present?

      identity.update!(attributes)
      user = identity.user
    else
      # Attach the identity to the current user if they are signed in, otherwise make a new user
      ActiveRecord::Base.transaction do
        user = current_user || User.create!
        identity = user.identities.create!(key_fields.merge(attributes))
      end
    end

    user.update!(current_identity_id: identity.id)

    if auth.provider == 'xivauth'
      character_ids = auth.extra.characters&.pluck(:lodestone_id)

      if character_ids.present?
        XivauthCharactersSyncJob.perform_async(user.id, character_ids)
      end
    end

    user
  end

  def self.ransackable_associations(auth_object = nil)
    if auth_object == :admin
      %w(identities)
    else
      []
    end
  end
end
