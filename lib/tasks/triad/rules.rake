require 'xiv_data'

namespace :triad do
  namespace :rules do
    desc 'Create the rules'
    task create: :environment do
      PaperTrail.enabled = false

      puts 'Creating rules'
      count = Rule.count

      rules = ALL_LOCALES.each_with_object({}) do |locale, h|
        XIVData.sheet('TripleTriadRule', locale: locale).each do |rule|
          next unless rule['Name'].present?

          data = h[rule['#']] || { id: rule['#'] }

          data["name_#{locale}"] = rule['Name']
          data["description_#{locale}"] = rule['Description']

          h[data[:id]] = data
        end
      end

      rules.values.each do |rule|
        if existing = Rule.find_by(id: rule[:id])
          existing.update!(rule) if updated?(existing, rule)
        else
          Rule.create!(rule)
        end
      end

      puts "Created #{Rule.count - count} new rules"
    end
  end
end
