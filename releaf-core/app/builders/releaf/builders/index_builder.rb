class Releaf::Builders::IndexBuilder
  include Releaf::Builders::View
  include Releaf::Builders::Collection

  def header_extras
    search_block
  end

  def dialog?
    false
  end

  def text_search_available?
    controller.searchable_fields.present?
  end

  def extra_search_available?
    extra_search_block.present?
  end

  def text_search_block
    return unless text_search_available?
    tag(:div, class: "text-search"){ text_search_content }
  end

  def text_search_content
    [tag(:input, "", name: "search", type: "text", value: params[:search], autofocus: true),
      button(nil, "search", type: "submit", title: t('Search'))]
  end

  def extra_search_content; end

  def extra_search_button
    button(t("Filter"), "search", type: "submit", title: t("Search"))
  end

  def extra_search_block
    if @extra_search
      @extra_search
    else
      content = extra_search_content
      @extra_search = tag(:div, class: ["extras",  "clear-inside"]){ [content, extra_search_button] } if content.present?
    end
  end

  def search_block
    parts = [text_search_block, extra_search_block].compact
    tag(:form, search_form_attributes){ parts } if parts.present?
  end

  def search_form_attributes
    classes = ["search", "clear-inside"]
    classes << "has-text-search" if text_search_available?
    classes << "has-extra-search" if extra_search_available?
    url = url_for(controller: controller_name, action: "index")

    {class: classes, action: url}
  end

  def section_header_text
    t("All resources")
  end

  def section_header_extras
    return unless collection.respond_to? :total_entries
    tag(:span, class: "extras totals") do
      t("Resources found", count: collection.total_entries, default: "%{count} resources found", create_plurals: true)
    end
  end

  def footer_blocks
    list = [footer_primary_block]
    list << pagination_block if pagination?
    list << footer_secondary_block
    list
  end

  def footer_primary_tools
    items = []
    items << resource_creation_button if feature_available? :create
    items
  end

  def pagination?
    collection.respond_to?(:page)
  end

  def pagination_block
    template.will_paginate(collection, class: "pagination", params: params.merge(ajax: nil),
                           renderer: "Releaf::PaginationRenderer::LinkRenderer",
                           outer_window: 0, inner_window: 2)
  end

  def resource_creation_button
    url = url_for(controller: controller_name, action: "new")
    text = t("Create new resource")
    button(text, "plus", class: "primary", href: url)
  end

  def section_body
    tag(:div, class: "body") do
      template.releaf_table(collection, template.resource_class, template.table_options)
    end
  end
end
