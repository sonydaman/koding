class ActivityUpdateWidgetController extends KDViewController

  loadView:(mainView)->

    mainView.registerListener
      KDEventTypes  : "AutoCompleteNeedsTagData"
      listener      : @
      callback      : (pubInst,event)=> 
        {callback,inputValue,blacklist} = event
        @fetchAutoCompleteDataForTags inputValue,blacklist,callback
    
    mainView.addWidgetPane
      paneName    : "update"
      mainContent : updateWidget = new ActivityStatusUpdateWidget
        cssClass  : "status-widget"
        callback  : (formData)=>
          updateWidget.switchToSmallView()
          @updateWidgetSubmit formData, (err, activity)=>
            unless err
              updateWidget.reset()
            else
              mainView.mainInputTabs.showPaneByName "update"
        

    mainView.addWidgetPane
      paneName    : "question"
      mainContent : questionWidget = new ActivityQuestionWidget 
        callback  : @questionWidgetSubmit

    codeSnippetPane = mainView.addWidgetPane
      paneName    : "codesnip"
      mainContent : codeWidget = new ActivityCodeSnippetWidget 
        delegate  : mainView
        callback  : (data)=>
          mainView.resetWidgets()
          @codeSnippetWidgetSubmit data, (err, activity)=>
            unless err
              codeWidget.reset()
            else
              mainView.mainInputTabs.showPaneByName "codesnip"

    mainView.addWidgetPane
      paneName    : "link"
      mainContent : linkWidget = new ActivityLinkWidget 
        callback  : @linkWidgetSubmit

    mainView.addWidgetPane
      paneName    : "tutorial"
      mainContent : tutorialWidget = new ActivityTutorialWidget 
        callback  : @tutorialWidgetSubmit

    mainView.addWidgetPane
      paneName    : "discussion"
      mainContent : discussionWidget = new ActivityDiscussionWidget 
        callback  : @discussionWidgetSubmit

    mainView.showPane "update"

    codeSnippetPane.registerListener
      KDEventTypes : 'PaneDidShow'
      listener     : @
      callback     : -> codeWidget.widgetShown()


  updateWidgetSubmit:(data, callback)->

    bongo.api.JStatusUpdate.create data, (err, activity)=>
      callback err, activity
      unless err
        @propagateEvent (KDEventType:"OwnActivityHasArrived"), activity
      else
        new KDNotificationView type : "mini", title : "There was an error, try again later!"

  codeSnippetWidgetSubmit:(data, callback)->

    bongo.api.JCodeSnip.create data, (err, codesnip) =>
      callback err, codesnip
      if err
        new KDNotificationView type : "mini", title : "There was an error, try again later!"
      else
        @propagateEvent (KDEventType:"OwnActivityHasArrived"), codesnip

  fetchAutoCompleteDataForTags:(inputValue,blacklist,callback)->

    bongo.api.JTag.byRelevance inputValue, {blacklist}, (err,tags)->
      unless err
        callback? tags
      else
        log "there was an error fetching topics"

  questionWidgetSubmit:(data)->
    log 'creating question', data
    bongo.api.JActivity.create {type: 'qa', activity: data}, (error) ->
      warn 'couldnt ask question', error if error
  
  linkWidgetSubmit:(data)->
    log 'sharing link', data
    bongo.api.JActivity.create {type: 'link', activity: data}, (error) ->
      warn 'couldnt save link', error if error

  tutorialWidgetSubmit:(data)->
    log 'sharing tutorial', data
    bongo.api.JActivity.create {type: 'tutorial', activity: data}, (error) ->
      warn 'couldnt save tutorial', error if error

  discussionWidgetSubmit:(data)->
    log 'starting discussion', data
    bongo.api.JActivity.create {type: 'discussion', activity: data}, (error) ->
      warn 'couldnt save discussion', error if error

