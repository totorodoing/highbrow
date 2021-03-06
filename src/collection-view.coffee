# A view that iterates over a Collection and renders an individual ItemView for each model.
class CollectionView extends ItemView
  constructor: ->
    super
    @itemView ?= @options.itemView || @constructor.module[@name+'Item']
    @children = {}
    @bindTo @collection, "add", (model, collection, options) =>
      view = @addChildView(model,options.index)
      view.render()
      @addItemHtml(@$el, view.$el, model)
      @onAdded(view.$el) if @onAdded
    @bindTo @collection, "remove", (item) => @removeChildView(item)
    @bindTo @collection, "reset", => @render()

  models: -> @collection.models

  view: ->
    if @collection.pageInfo then @collection.pageInfo() else {}

  # Loop through all of the items and render each of them with the specified `itemView`.
  render: ->
    @renderTemplate()
    _.each @children, (childView) -> childView.close()
    _.each @models(), (model, index) =>
      view = @addChildView(model,index).render()
      @appendHtml(@$el, view.$el, model)
    @onRender()
    @

  # build and store the child view
  addChildView: (item, index) -> @storeChild(@buildItemView(item, index))

  buildItemView: (item, index) -> new @itemView({model: item, index, parent: @, namespace: @namespace})

  # Remove the child view and close it
  removeChildView: (item) ->
    return unless @children[item.cid]
    @children[item.cid].close()
    delete @children[item.cid]

  # Append the HTML to the collection's `el`. Override this method to do something other 
  # than `.append`.
  appendHtml: (el, html, model) -> @$el.append(html)

  # TODO: rename appendHtml to addItemHtml
  addItemHtml: (el, html, model) -> @appendHtml(el, html, model)

  # Store references to all of the child `itemView`
  # instances so they can be managed and cleaned up, later.
  storeChild: (view) -> @children[view.model.cid] = view

  # Handle cleanup and other closing needs for
  # the collection of views.
  close: ->
    _.each @children, (childView) -> childView.close()
    @children = {}
    super

  # Override for custom code on dom show
  onShow: ->
    _.each @children, (childView) -> childView.onShow()

