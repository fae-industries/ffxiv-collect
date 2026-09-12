json.cache! [@beast, I18n.locale] do
  json.partial! 'api/beasts/beast', beast: @beast, owned: @owned
end
