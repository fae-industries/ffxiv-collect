json.query @query
json.count @beasts.length
json.results do
  json.cache! [@beasts, I18n.locale] do
    json.partial! 'api/beasts/beast', collection: @beasts, as: :beast
  end
end
