require "rails_helper"

describe Releaf::Builders::IndexBuilder, type: :class do
  class TranslationsIndexBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
    delegate :resource_class, :table_options, to: :controller

    def controller
      @controller ||= begin
                        c = Admin::BooksController.new
                        c.setup
                        c
                      end
    end
  end

  let(:template){ TranslationsIndexBuilderTestHelper.new }
  let(:subject){ described_class.new(template) }
  let(:collection){ Book.page(1).per_page(2) }

  before do
    allow(subject).to receive(:controller_name).and_return("_controller_name_")
    allow(subject).to receive(:collection).and_return(collection)
  end

  it "includes Releaf::Builders::View" do
    expect(described_class.ancestors).to include(Releaf::Builders::View)
  end

  it "includes Releaf::Builders::Collection" do
    expect(described_class.ancestors).to include(Releaf::Builders::Collection)
  end

  describe "#dialog?" do
    it "returns false" do
      expect(subject.dialog?).to be false
    end
  end

  describe "#search_block" do
    before do
      allow(subject).to receive(:text_search_block).and_return("aa")
      allow(subject).to receive(:extra_search_block).and_return("bb")
      allow(subject).to receive(:search_form_attributes).and_return(a: "xx")
    end

    it "returns search from with attributes and text/extra search blocks" do
      expect(subject.search_block).to eq('<form a="xx">aabb</form>')
    end

    context "when no text blocks available" do
      it "returns nil" do
        allow(subject).to receive(:text_search_block).and_return(nil)
        allow(subject).to receive(:extra_search_block).and_return(nil)
        expect(subject.search_block).to be nil
      end
    end
  end

  describe "#search_form_attributes" do
    before do
      allow(subject).to receive(:text_search_available?).and_return(true)
      allow(subject).to receive(:extra_search_available?).and_return(true)
      allow(subject.template).to receive(:url_for).with(controller: "_controller_name_", action: "index").and_return("x")
    end

    it "returns url and css classes for search form" do
      classes = ["search", "clear-inside", "has-text-search", "has-extra-search"]
      expect(subject.search_form_attributes).to eq(class: classes, action: "x")
    end

    context "when text search is not available" do
      it "does not add text search class" do
        allow(subject).to receive(:text_search_available?).and_return(false)
        expect(subject.search_form_attributes[:class]).to_not include("has-text-search")
      end
    end

    context "when extra search is not available" do
      it "does not add extra search class" do
        allow(subject).to receive(:extra_search_available?).and_return(false)
        expect(subject.search_form_attributes[:class]).to_not include("has-extra-search")
      end
    end
  end

  describe "#header_extras" do
    it "returns search block" do
      allow(subject).to receive(:search_block).and_return("x")
      expect(subject.header_extras).to eq("x")
    end
  end

  describe "#extra_search_available?" do
    context "when extra search block is present" do
      it "returns true" do
        allow(subject).to receive(:extra_search_block).and_return("x")
        expect(subject.extra_search_available?).to be true
      end
    end

    context "when extra search block is nil" do
      it "returns false" do
        allow(subject).to receive(:extra_search_block).and_return(nil)
        expect(subject.extra_search_available?).to be false
      end
    end
  end

  describe "#text_search_available?", focus: true do
    context "when template variable `searchable_fields` is present" do
      it "returns true" do
        allow( template.controller ).to receive(:searchable_fields).and_return([:a])
        expect(subject.text_search_available?).to be true
      end
    end

    context "when template variable `searchable_fields` is blank" do
      it "returns false" do
        allow( template.controller ).to receive(:searchable_fields).and_return([])
        expect(subject.text_search_available?).to be false
      end
    end
  end

  describe "#text_search_block" do
    before do
      allow(subject).to receive(:text_search_content).and_return("x")
    end

    context "when text search is available" do
      it "returns true" do
        allow(subject).to receive(:text_search_available?).and_return(true)
        expect(subject.text_search_block).to eq('<div class="text-search">x</div>')
      end
    end

    context "when text search is not available" do
      it "returns false" do
        allow(subject).to receive(:text_search_available?).and_return(false)
        expect(subject.text_search_block).to be nil
      end
    end
  end

  describe "#text_search_content" do
    it "returnsu array with text search input and button" do
      allow(subject).to receive(:t).with('Search').and_return("sss")
      allow(subject).to receive(:params).and_return(search: "xxx")
      allow(subject).to receive(:button)
        .with(nil, "search", type: "submit", title: 'sss')
        .and_return("btn")
      expect(subject.text_search_content).to eq(['<input name="search" type="text" value="xxx" autofocus="autofocus"></input>',
                                                 "btn"])
    end
  end

  describe "#extra_search_content" do
    it "returns nil(available for override)" do
      expect(subject.extra_search_content).to be nil
    end
  end

  describe "#extra_search_button" do
    it "returns extra search button" do
      allow(subject).to receive(:t).with('Search').and_return("sss")
      allow(subject).to receive(:t).with('Filter').and_return("fff")
      allow(subject).to receive(:button)
        .with("fff", "search", type: "submit", title: 'sss')
        .and_return("xx")
      expect(subject.extra_search_button).to eq("xx")
    end
  end

  describe "#extra_search_block" do
    before do
      allow(subject).to receive(:extra_search_button).and_return("btn")
      allow(subject).to receive(:extra_search_content).and_return("xx")
    end

    it "returns extra search block" do
      expect(subject.extra_search_block).to eq('<div class="extras clear-inside">xxbtn</div>')
    end

    it "caches extra search content" do
      allow(subject).to receive(:extra_search_content).and_return("xx").once
      subject.extra_search_block
      subject.extra_search_block
    end

    context "when extra search content is not present" do
      it "returns nil" do
        allow(subject).to receive(:extra_search_content).and_return(nil)
        expect(subject.extra_search_block).to be nil
      end
    end
  end

  describe "#section_header_text" do
    it "returns section header text" do
      allow(subject).to receive(:t).with('All resources').and_return("all")
      expect(subject.section_header_text).to eq("all")
    end
  end

  describe "#section_header_extras" do
    it "returns true" do
      allow(subject).to receive(:t)
        .with("Resources found", count: 0, default: "%{count} resources found", create_plurals: true)
        .and_return("sss")
      expect(subject.section_header_extras).to eq('<span class="extras totals">sss</span>')
    end

    context "when collection does not respond to total_entries" do
      it "returns nil" do
        allow(subject).to receive(:collection).and_return(Book.all)
        expect(subject.section_header_extras).to be nil
      end
    end
  end

  describe "#footer_blocks" do
    before do
      allow(subject).to receive(:footer_primary_block).and_return("a")
      allow(subject).to receive(:pagination_block).and_return("b")
      allow(subject).to receive(:footer_secondary_block).and_return("c")
      allow(subject).to receive(:pagination?).and_return(true)
    end

    it "returns array with footer primary, pagination and secondary blocks" do
      expect(subject.footer_blocks).to eq(["a", "b", "c"])
    end

    context "when pagination is not available" do
      it "does not include pagination block within returned array" do
        allow(subject).to receive(:pagination?).and_return(false)
        expect(subject.footer_blocks).to eq(["a", "c"])
      end
    end
  end

  describe "#footer_primary_tools" do
    before do
      allow(subject).to receive(:resource_creation_button).and_return("a")
      allow(subject).to receive(:feature_available?).with(:create).and_return(true)
    end

    it "returns array with resource creation button" do
      expect(subject.footer_primary_tools).to eq(["a"])
    end

    context "when creation feature is not available" do
      it "returns empty array" do
        allow(subject).to receive(:feature_available?).with(:create).and_return(false)
        expect(subject.footer_primary_tools).to eq([])
      end
    end
  end

  describe "#pagination?" do
    context "when collection responds to `page` method" do
      it "returns true" do
        expect(subject.pagination?).to be true
      end
    end

    context "when collection does not respond to `page` method" do
      it "returns false" do
        allow(subject).to receive(:collection).and_return(Book.all)
        expect(subject.pagination?).to be true
      end
    end
  end

  describe "#pagination_block" do
    it "returns pagination helper" do
      allow(subject).to receive(:params).and_return(search: "xxx", ajax: true)
      allow(template).to receive(:will_paginate)
        .with(collection, class: "pagination", params: {search: "xxx", ajax: nil},
            renderer: "Releaf::PaginationRenderer::LinkRenderer", outer_window: 0, inner_window: 2)
        .and_return("x")
      expect(subject.pagination_block).to eq("x")
    end
  end

  describe "#resource_creation_button" do
    it "returns resource creation button" do
      allow(subject.template).to receive(:url_for).with(controller: "_controller_name_", action: "new").and_return("x")
      allow(subject).to receive(:t).with('Create new resource').and_return("sss")
      allow(subject).to receive(:button)
        .with("sss", "plus", class: "primary", href: "x")
        .and_return("btn")
      expect(subject.resource_creation_button).to eq("btn")
    end
  end

  describe "#section_body" do
    it "returns collection table" do
      allow(template).to receive(:releaf_table)
        .with(collection, Book, builder: Admin::Books::TableBuilder, toolbox: true)
        .and_return("xx")
      expect(subject.section_body).to eq('<div class="body">xx</div>')
    end
  end
end
