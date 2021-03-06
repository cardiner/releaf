## Changelog
### 2015.11.12
* `current_params` method removed from `Releaf::BaseController`. Is it
  recommended to simply use `request.query_parameters` instead.

### 2015.11.09
* Refactored Releaf node public route definition syntax.
  Old syntax:
  ```ruby
  Rails.application.routes.draw do
    Releaf::Content::Route.for(HomePage).each do |route|
      get route.params('home_pages#show')
    end
  end
  ```

  New equivalent:
  ```ruby
  Rails.application.routes.draw do
    releaf_routes_for(HomePage) do
      get 'show'
    end
  end
  ```

  ```releaf_routes_for``` accepts two parameters: node content class and
  optional options hash. By default ```releaf_routes_for``` routes requests to
  pluralized content class name controller (HomePage -> HomePagesController).
  It is possible to owerride default providing ```:controller``` option with
  string representation of controllers name (such as ```'text_pages```', which
  will route to ```TextPagesController```).
  Example:
  ```ruby
  releaf_routes_for(HomePage, controller: 'text_pages') do
    get 'show'
  end
  ```

  ```releaf_routes_for``` supports all simple route definition methos such as
  ```get```, ```put```, ```patch```, ```post```, ```delete``` etc.
  ```resources```, ```resource```, ```scope```, ```namespace``` however aren't
  supported and will cause unexpected behaviour (most likely an exception), if
  used.

  Old syntax is still supported, however it is advised to migrate to new syntex.

  Here are all possible examples of new syntax (Given node.url is ```/examples```):
  ```ruby
  releaf_routes_for(HomePage) do
    get 'index' # GET '/examples' => HomePagesController#index
    get ':id' # GET '/examples/12' => HomePagesController#show, id == '12'
    delete ':id' # DELETE '/examples/12' => HomePagesController#destroy, id == '12'
    get ':id/details', to: 'details#show' # GET '/examples/12/details' => DetailsController#show, id == '12'
  end

  releaf_routes_for(TextPage, controller: 'info_pages') do
    get 'index' # GET '/examples' => InfoPagesController#index
    delete 'text_pages#destroy' # DELETE '/examples' => TextPagesController#destroy
    get 'info', to: '#info' # GET '/examples/info' => InfoPagesController#info
    get 'full-info', to: 'advanced_info_pages#info' # GET '/examples/full-info' => AdvancedInfoPagesController#info
  end
  ```

  Naturally you can pass ```:as```, ```:constraints``` and other options supported by regular ```get```, ```put``` and other methods.

  General rules of thumb:
  1) to create route to default contrller and to url of node, then just create
    route with string target method name:
    ```ruby
    releaf_routes_for(TextPage) do
      get 'index'
    end
    ```
  2) to create route to different controller, add ```:to``` option and specify
    controller and action:
    ```ruby
    releaf_routes_for(TextPage) do
      get 'list', to: 'info_pages#index'
    end
    ```
  3) to create route with additonal url, that routes to default controller,
    don't specify controller controller in ```:to``` option:
    ```ruby
    releaf_routes_for(TextPage) do
      get 'list', to: '#index'
    end
    ```
  4) To route to differnt contrller from node url, just specify controller and
    action as first argument:
    ```ruby
    releaf_routes_for(TextPage) do
      get 'info_pages#show'
    end
    ```
  5) to change default controller, pass ```:controller``` argument:
    ```ruby
    releaf_routes_for(TextPage, controller: 'info_pages') do
      get 'index'
    end
    ```

  Feel free to investigage
  [pull request](https://github.com/cubesystems/releaf/pull/246)
  and especially
  [routing tests](https://github.com/graudeejs/releaf/blob/05e1b7062e4bdc25e8457b338061b2e0bae76159/releaf-content/spec/routing/node_mapper_spec.rb)


### 2015.10.14
* `Releaf::Core::Application` and `Releaf::Core::Configuration` introduced
* From now all settings is available through `Releaf.application.config`
  instead of `Releaf`
* Releaf initalizer must be updated by changing `Releaf.setup do |conf|` to `Releaf.application.configure do` and
  replacing all `conf.` with `config.`
* change `conf.layout_builder = CustomLayoutBuilder``` to `config.layout_builder_class_name = 'CustomLayoutBuilder'`

### 2015.08.05
* Renamed `Releaf::TemplateFieldTypeMapper` to `Releaf::Core::TemplateFieldTypeMapper`
* Renamed `Releaf::AssetsResolver` to `Releaf::Core::AssetsResolver`
* Renamed `Releaf::ErrorFormatter` to `Releaf::Core::ErrorFormatter`
* Moved `Releaf::Responders` under `Releaf::Core` namespace

### 2015.08.04
* refactored `@searchable_fields`. Now you should override `#searchable_fields`
  method instead. By default searchable fields will be guessed with help of
  `Releaf::Core::DefaultSearchableFields`
* Renamed `Releaf::Search` to `Releaf::Core::Search`

### 2015.08.01
* Releaf::Builders::IndexBuilder has been refactored with following changes:
  - `search` method renamed to `search_block`
  - `extra_search` method renamed to `extra_search_block`
  - `pagination` method renamed to `pagination_block`
  - section header text and resources count translations renamed
* "global.admin" translation scope has been removed in favour of controller name scope

### 2015.07.23
* Releaf::ResourceFinder was refactored and renamed to Releaf::Search.
  If you used Releaf::ResourceFinder somewhere, you need to change
  ```ruby
  relation = Releaf::ResourceFinder.new(resource_class).search(parsed_query_params[:search], @searchable_fields, relation)
  ```
  to
  ```ruby
  relation = Releaf::Search.prepare(relation: relation, text: parsed_query_params[:search], fields: @searchable_fields)
  ```

### 2015.01.09
* Controller name scoped builders implemented.
  More there: http://cubesystems.github.io/releaf/documentation/builders.html#creation

### 2014.12.04
* BaseController 'resource_params' method renamed to 'permitted_params'

### 2014.09.15
* Releaf controllers now properly resolves namespaced classes
  For example Admin::Foo::BarsController previously would resolve to Bar class,
  now it will resolve to Foo::Bar class

### 2014.07.02
* TinyMCE replaced by CKEditor as built-in WYSIWYG field editor

### 2014.07.01
* Settings module renamed to Releaf::Settings.
* Releaf::Core::SettingsUIComponent component added.
  More there: https://github.com/cubesystems/releaf/wiki/Settings

### 2014.06.09
* Richtext attachments moved to releaf component/controller concern.
  More there: https://github.com/cubesystems/releaf/wiki/Richtext-editor

### 2014.05.28
* Removed Releaf::TemplateFilter includable module.
* Refactored how releaf stores form templates.
  Form templates are now stored in containers data-releaf-template html attribute.

### 2014.05.15
* Releaf::ResourceValidator was renamed to Releaf::ErrorFormatter.
  Releaf::ErrorFormatter.build_validation_errors was renamed to .format_errors.

  If you used Releaf::ResourceValidator.build_validation_errors, update your
  code to use Releaf::ErrorFormatter.format_errors.

### 2014.05.14
* Releaf::ResourceValidator was rewriten.
  .build_validation_errors now only needs one argument - resource to validate.

  It will now use "activerecord.errors.messages.[model_name]" as I18n scope for errors
* BaseController 'index_row_toolbox' feature renamed to 'toolbox'

### 2014.05.09
* Translation group removed
* Translations refactored

### 2014.05.01
* Dragonfly updated from 0.9 to 1.0
  Update instructions there: https://github.com/markevans/dragonfly/wiki/Upgrading-from-0.9-to-1.0

### 2014.04.30
* removed #protected attribute from releaf node
* To render locale selection for content node override
  \#locale_selection_enabled? method to return true for nodes that need locale
  selector.

  This means that Releaf no longer check for releaf/content/_edit.locale
  partial. This partial will be ignored.

  Rename Releaf::Permissions::Admin to Releaf::Permissions::User,
  change table name from releaf_admins to releaf_users
* Modify releaf_roles.permisions to match changed naming for releaf/content/nodes, releaf/permissions/users,   releaf/permissions/roles, releaf/i18n_database/translations
* Modify releaf_roles.default_controller to be an existing one (for example from releaf/content to releaf/content/nodes)
* Modify config/initializers/releaf.rb to use releaf/content/nodes, releaf/permissions/users, releaf/permissions/roles, releaf/i18n_database/translations

### 2014.04.28
* Refactored notification rendering (introduced
  Releaf::BaseController#render_notification) method.

  Now notifications by default will consist of action name and "succeeded" or
  "failed" word. For example flash notice "Updated" will now be
  "Update succeeded".

### 2014.04.25
* It is no longer required to add :id to permit_attributes options for
  ActiveRecord models, when using acts_as_node. It'll be added automatically,
  when permit_attributes option is used.

### 2014.04.23
* Converted Releaf::Node to Releaf::Contnet::Node module.

  Instread of inheriting from Releaf::Node, inherit from ActiveRecord::Base and
  include Releaf::Content::Node

### 2014.04.22
* Releaf::Node is in refactoring process. The goal is to make it an abstract
  model (some day)

  All existing projects that use Releaf::Node should create Node model that inherits
  from Releaf::Node. You will either need to rename releaf_nodes table to
  nodes or set table_name in Node model.

  In all of your code you should use Node model now (instead of Releaf::Node).
  This includes migrations as well.

  If you used Releaf::Node model in migrations, then it might be nessacery to
  rename releaf_nodes table renaming migration in such a way, that it renames
  table, before any other migration needs to access Node. Otherwise you'll get
  chicken and egg situation, when migration tries to access nodes table, while
  releaf_nodes table will be renamed to nodes much later.

  Currently there is no way to specify alternative Node model.

* Got rid of common fields.

  If you were using common fields, you should migrate your data from common
  fields seralized hash (in data attribute), to attribute per common field.

* To use new common field attributes, crete method 'own_fields_to_display' in your node model, that returns common attributes, for example:
  def own_fields_to_display
    [:page_title, :meta_description]
  end

* Remove custom validations support from Releaf::Node via acts_as_node.

  Instead you should add custom validations to your Node model

* Renamed Releaf::Node::Route to Releaf::ContentRoute

### 2014.04.09
* remove Releaf::Node#content_string field, as it was't used
* Extend Releaf::Node#data column to 2147483647 characters

### 2014.01.02
* ```additional_controllers``` Releaf configuration variable introduced. Add
  controllers that are not accessible via menu, but needs to be accessible by
  admins to this list.  These controllers will have permission checkbox in
  roles edit view, just like the rest of controllers in ```Releaf.menu```.

### 2013.12.05
* \#build_validation_errors, #validation_attribute_name,
  \#validation_attribute_field_id, and #validation_attribute_nested_field_name
  were extracted from Releaf::BaseController to Releaf::ResourceValidator module.
  If you called any of these methods manually, then you'll need to update your
  controllers. Also Releaf::ResourceValidator.build_validation_errors now
  accept two arguments: resource and error message scope (check the source from
  details)

* Extracted functionality of filtering templates from params from
  Releaf::BaseController to Releaf::TemplateFilter includable module.
  You can now include this module in your controllers if you want similar
  functionality.


### 2013.11.01
* Bump font-awesome-rails to >= 4.0.1.0. If you use it, update all
  html/css/javascript to use new font awesome classes


### 2013.10.24

* Removed long unused lighbox javascript
* ajaxbox now checks presence of ```data-modal``` attrubute instead of it's value. Update your views.
* If you want to open image in ajaxbox, you need to add ```rel="image"``` html attribute to links.


### 2013.10.17

* Moved ```Releaf::BaseController#resource_class``` functionality to
  ```Releaf::BaseController.resource_class```.
  ```Releaf::BaseController#resource_class``` now calls ```Releaf::BaseController.resource_class```.
  Everywhere, where ```Releaf::BaseController#resource_class``` was overriden,
  you must update your code, to override
  ```Releaf::BaseController.resource_class```
* Renamed ```@resources``` to ```@collection```
* Renamed ```Releaf::BaseController#resources_relation``` to ```Releaf::BaseController#resources```
* Updated html and css to use collection class instead of resources class
* Richtext field height will be set to outerHeight() of textarea
* ```Releaf::BaseController#render_field_type``` was extracted to
  ```Releaf::TemplateFieldTypeMapper``` module.
  It's functionality was split.

  ```ruby
    render_field_type, use_i18n = render_field_type(resource, field_name)
  ```

  should now be rewriten to

  ```ruby
    field_type_name = Releaf::TemplateFieldTypeMapper.field_type_name(resource, field_name)
    use_i18n = Releaf::TemplateFieldTypeMapper.use_i18n?(resource, field_name)
  ```
* created new helper method ```ajax?```. If you were checking
  ```params[:ajax]``` or ```params.has_key?(:ajax)``` etc, then you should
  update your code to use ```ajax?```.

  ```:ajax``` parameter is removed from ```params``` has in ```manage_ajax```
  before filter in ```Releaf::BaseApplicationController```
