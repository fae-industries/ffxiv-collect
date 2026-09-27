module Triad::NPCsHelper
  def quest(npc)
    if npc.quest.present?
      link_to(npc.quest.name, "https://www.garlandtools.org/db/#quest/#{npc.quest_id}", target: '_blank')
    end
  end

  def format_npc_name(npc)
    if npc.excluded?
      tooltip = content_tag(:span, fa_icon('exclamation-circle'), data: { toggle: 'tooltip' },
                            title: 'Does not count for Triple Team achievements')
      "#{npc.name} #{tooltip}".html_safe
    else
      npc.name
    end
  end

  def format_rules(npc, inline: false)
    npc.rules.map(&:name).sort.join(inline ? ', ' : '<br>').html_safe
  end

  def difficulty(npc)
    (fa_icon('star') * npc.difficulty.ceil).html_safe
  end

  def npc_defeated?(npc)
    current_user.npcs.include?(npc)
  end

  def npc_rule_options(selected)
    options_for_select(Rule.joins(:npcs).order(Rule.current_locale_column(:name)).uniq.map(&:name), selected)
  end
end
