json.(beast, :id, :name, :description, :patch)

json.trick beast.trick.description
json.tempered_release beast.tempered_release.description
json.owned @owned.fetch(beast.id.to_s, '0%')
json.image beast.image_url

json.partial! 'api/shared/sources', collectable: beast
