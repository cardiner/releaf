module Releaf::Content
  class NodesController < Releaf::BaseController
    respond_to :json, only: [:create, :update, :copy, :move]

    def generate_url
      tmp_resource = prepare_resource
      tmp_resource.name = params[:name]
      tmp_resource.reasign_slug

      respond_to do |format|
        format.js { render text: tmp_resource.slug }
      end
    end

    def content_type_dialog
      @content_types = resource_class.valid_node_content_classes(params[:parent_id]).sort do |a, b|
        I18n.t(a.name.underscore, scope: 'admin.content_types') <=> I18n.t(b.name.underscore, scope: 'admin.content_types')
      end
    end

    def builder_scopes
      [node_builder_scope] + super
    end

    def node_builder_scope
      [application_scope, "Nodes"].reject(&:blank?).join("::")
    end

    def copy_dialog
      copy_move_dialog_common
    end

    def move_dialog
      copy_move_dialog_common
    end

    def copy
      copy_move_common do |resource|
        resource.copy params[:new_parent_id]
      end
    end

    def move
      copy_move_common do |resource|
        resource.move params[:new_parent_id]
      end
    end

    def go_to_dialog
      @collection = resource_class.roots

      respond_to do |format|
        format.html do
          render layout: nil
        end
      end
    end

    # override base_controller method for adding content tree ancestors
    # to breadcrumbs
    def add_resource_breadcrumb(resource)
      ancestors = []
      if resource.new_record?
        if resource.parent_id
          ancestors = resource.parent.ancestors
          ancestors += [resource.parent]
        end
      else
        ancestors = resource.ancestors
      end

      ancestors.each do |ancestor|
        @breadcrumbs << { name: ancestor, url: url_for( action: :edit, id: ancestor.id ) }
      end

      super
    end

    def self.resource_class
      ::Node
    end

    protected

    def prepare_index
      @collection = resource_class.roots
    end

    private

    def copy_move_common(&block)
      @resource = resource_class.find(params[:id])

      if params[:new_parent_id].nil?
        @resource.errors.add(:base, 'parent not selected')
        respond_with(@resource)
      else
        begin
          @resource = yield(@resource)
        rescue ActiveRecord::RecordInvalid => e
          respond_with(e.record)
        else
          resource_class.updated
          respond_with(@resource, redirect: true, location: url_for(action: :index))
        end
      end
    end

    def action_responders
      super.merge(
        copy: Releaf::Core::Responders::AfterSaveResponder,
        move: Releaf::Core::Responders::AfterSaveResponder
      )
    end

    def copy_move_dialog_common
      @resource = resource_class.find params[:id]
      @collection = resource_class.roots
    end

    def prepare_resource
      if params[:id]
        resource_class.find(params[:id])
      elsif params[:parent_id].present?
        parent = resource_class.find(params[:parent_id])
        parent.children.new
      else
        resource_class.new
      end
    end

    def new_resource
      super
      @resource.content_type = node_content_class.name
      @resource.parent_id = params[:parent_id]
      @resource.item_position ||= resource_class.children_max_item_position(@resource.parent) + 1

      if node_content_class < ActiveRecord::Base
        @resource.build_content
        @resource.content_id_will_change!
      end
    end

    # Returns valid content type class
    def node_content_class
      raise ArgumentError, "invalid content_type" unless ActsAsNode.classes.include? params[:content_type]
      params[:content_type].constantize
    end

    def permitted_params
      list = super
      list += [{content_attributes: permitted_content_attributes}]
      list -= %w[content_type]
      list
    end

    def permitted_content_attributes
      @resource.content_class.acts_as_node_params if @resource.content_class.respond_to? :acts_as_node_params
    end
  end
end
