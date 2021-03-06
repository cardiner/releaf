require "rails_helper"

describe Releaf::Content::Route do
  let(:node_route) { FactoryGirl.build(:node_route, node_id: 12, locale: "en", path: "/en") }

  describe ".node_class" do
    it "returns ::Node" do
      expect( described_class.node_class ).to eq ::Node
    end
  end

  describe ".node_class_default_controller" do
    context "when given node class inherits `ActionController::Base`" do
      it "returns undercored, stripped down controller class" do
        expect(described_class.node_class_default_controller(HomePagesController)).to eq("home_pages")
      end
    end

    context "when given node class does not inherit `ActionController::Base`" do
      it "returns pluralized, underscorized class" do
        expect(described_class.node_class_default_controller(TextPage)).to eq("text_pages")
      end
    end
  end

  describe ".for" do
    before do
      create(:home_page_node)
    end

    it "returns an array" do
      expect(described_class.for(HomePage, 'foo').class).to eq(Array)
    end

    context "when databse doesn't exists" do
      it "returns an empty array" do
        allow(described_class.node_class).to receive(:where).and_raise(ActiveRecord::NoDatabaseError.new("xxx"))
        expect(described_class.for(HomePage, 'foo')).to eq([])
      end
    end

    context "when releaf_nodes table doesn't exists" do
      it "returns an empty array" do
        allow(described_class.node_class).to receive(:where).and_raise(ActiveRecord::StatementInvalid.new("xxx"))
        expect(described_class.for(HomePage, 'foo')).to eq([])
      end
    end

    context "when releaf_nodes table exists" do
      it "returns an array of Node::Route objects" do
        result = described_class.for(HomePage, 'foo')
        expect(result.count).to eq(1)
        expect(result.first.class).to eq(described_class)
      end

      context "when node is not available" do
        it "does not include it in return" do
          allow_any_instance_of(Node).to receive(:available?).and_return(false)
          expect(described_class.for(HomePage, 'foo')).to eq([])
        end
      end
    end
  end

  describe '#params' do
    it "returns params for router method" do
      expect(node_route.params("home#index")).to eq ['/en', {:node_id=>"12", :locale=>"en", :to=>"home#index"}]
    end

    context "when :as given in args" do
      context "when node has a locale" do
        it "prepends locale to :as" do
          expect(node_route.params("home#index", as: "home").last).to match hash_including(as: "en_home")
        end
      end

      context "when node does not have a locale" do
        it "doesn't modify :as option" do
          node_route.locale = nil
          expect(node_route.params("home#index", as: "home").last).to match hash_including(as: "home")
        end
      end
    end
  end
end
