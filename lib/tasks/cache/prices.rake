UNIVERSALIS_BASE_URL = 'https://universalis.app/api/v2'.freeze
USER_AGENT = 'FFXIVCollect'.freeze

namespace :cache do
  desc 'Sets the latest known market board prices for items by data center'
  task prices: :environment do
    item_ids = Item.where(tradeable: true).where.not(unlock_id: nil).pluck(:id) +
      Leve.where.not(item_id: nil).distinct.order(:item_id).pluck(:item_id)
    item_ids << 32830 # Add "Paint It X" which is missed due to multiple unlock IDs

    Character.universalis_regions.values.each do |region|
      log("Updating prices for #{region}")
      key = "prices-#{region.underscore}"

      Redis.current.set("#{key}-last-updated", Time.now.utc.to_formatted_s(:usec))

      item_ids.each_slice(100) do |ids|
        begin
          url = "#{UNIVERSALIS_BASE_URL}/#{region}/#{ids.join(',')}?listings=1&entries=0"
          response = RestClient.get(url, { params: { listings: 1, entries: 0 }, user_agent: USER_AGENT })

          prices = JSON.parse(response)['items'].map do |id, item|
            time = item['lastUploadTime'].to_i
            last_updated = time == 0 ? nil : Time.at(time / 1000).to_date
            price, world = item['listings'].first&.values_at('pricePerUnit', 'worldName')

            [id, { price: price, world: world, last_updated: last_updated }.to_json]
          end

          Redis.current.hmset(key, prices.flatten)
        rescue RestClient::ExceptionWithResponse => e
          log("There was a problem fetching #{url} (#{e.http_code})")
        rescue
          log("There was an unexpected problem fetching #{url}")
        end
      end
    end
  end
end
