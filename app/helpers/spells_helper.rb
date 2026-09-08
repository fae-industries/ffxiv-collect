module SpellsHelper
  def rank_options
    (1..5).to_a.reverse.map { |x| ["\u2605" * x, x] }
  end

  def spell_aspect(spell)
    spell.type.name_en == 'Physical' ? t('spells.damage') : t('spells.aspect')
  end

  def spell_rank(spell)
    stars(spell.rank)
  end
end
