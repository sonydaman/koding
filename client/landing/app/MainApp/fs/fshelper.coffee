class FSHelper

  parseWatcherFile = (parentPath, file, user)->

    {name, size, mode} = file
    createdAt          = file.time
    type               = if file.isBroken then 'brokenLink' else \
                         if file.isDir then 'folder' else 'file'
    path               = parentPath + '/' + name
    group              = user

    # Fix that when we implemented RemoteDrives
    # if type is 'folder'
    #   if /^\/home\/(.*)\/RemoteDrives(|\/([^\/]+))$/gm.test path
    #     type = 'mount'

    return { size, user, group, createdAt, mode, type, parentPath, path, name }

  @parseWatcher = (parentPath, files)->

    data = []
    return data unless files
    files = [files] unless Array.isArray files

    sortedFiles = []
    for p in [yes, no]
      z = [x for x in files when x.isDir is p][0].sort (x,y)-> x.name > y.name
      sortedFiles.push x for x in z

    {nickname} = KD.whoami().profile
    for file in sortedFiles
      data.push FSHelper.createFile parseWatcherFile parentPath, file, nickname

    return data

  @folderOnChange = (path, change, treeController)->
    console.log "THEY CHANGED:", change, treeController
    file = @parseWatcher(path, change.file).first
    switch change.event
      when "added"
        treeController.addNode file
      when "removed"
        for npath, node of treeController.nodes
          if npath is file.path
            treeController.removeNodeView node
            break

  @grepInDirectory = (keyword, directory, callback, matchingLinesCount = 3) ->
    command = "grep #{keyword} '#{directory}' -n -r -i -I -H -T -C#{matchingLinesCount}"
    KD.getSingleton('kiteController').run command, (err, res) =>
      result = {}

      if res
        chunks = res.split "--\n"

        for chunk in chunks
          lines = chunk.split "\n"

          for line in lines when line
            [lineNumberWithPath, line] = line.split "\t"
            [lineNumber]               = lineNumberWithPath.match /\d+$/
            path                       = lineNumberWithPath.split(lineNumber)[0].trim()
            path                       = path.substring 0, path.length - 1
            isMatchedLine              = line.charAt(1) is ":"
            line                       = line.substring 2, line.length

            result[path] = {} unless result[path]
            result[path][lineNumber] = {
              lineNumber
              line
              isMatchedLine
              path
            }

      callback? result

  @exists = (path, callback=noop)->
    @getInfo path, (err, res)->
      callback err, res?

  @getInfo = (path, callback=noop)->
    KD.getSingleton('kiteController').run
      method   : "fs.getInfo"
      withArgs : {path}
    , callback

  @ensureNonexistentPath = (path, callback=noop)->
    KD.getSingleton('kiteController').run
      method   : "fs.ensureNonexistentPath"
      withArgs : {path}
    , callback

  @registry = {}

  @register = (file)->
    @setFileListeners file
    @registry[file.path] = file

  @deregister = (file)->
    delete @registry[file.path]

  @updateInstance = (fileData)->
    for prop, value of fileData
      @registry[fileData.path][prop] = value

  @setFileListeners = (file)->
    file.on "fs.rename.finished", =>

  @getFileNameFromPath = getFileName = (path)->
    return path.split('/').pop()

  @trimExtension = (path)->
    name = getFileName path
    return name.split('.').shift()

  @getParentPath = (path)->
    path = path.substr(0, path.length-1) if path.substr(-1) is "/"
    parentPath = path.split('/')
    parentPath.pop()
    return parentPath.join('/')

  @createFileFromPath = (path, type = "file")->
    return warn "pass a path to create a file instance" unless path
    parentPath = @getParentPath path
    name       = @getFileNameFromPath path
    return @createFile { path, parentPath, name, type }

  @createFile = (data)->
    unless data and data.type and data.path
      return warn "pass a path and type to create a file instance"

    if @registry[data.path]
      instance = @registry[data.path]
      @updateInstance data
    else
      constructor = switch data.type
        when "folder"     then FSFolder
        when "mount"      then FSMount
        when "symLink"    then FSFolder
        when "brokenLink" then FSBrokenLink
        else FSFile

      instance = new constructor data
      @register instance

    return instance

  @isValidFileName = (name) ->
    return /^([a-zA-Z]:\\)?[^\x00-\x1F"<>\|:\*\?/]+$/.test name

  @isEscapedPath = (path) ->
    return /^\s\"/.test path

  @escapeFilePath = (name) ->
    return name.replace(/\'/g, '\\\'').replace(/\"/g, '\\"').replace(/\ /g, '\\ ')

  @unescapeFilePath = (name) ->
    return name.replace(/^(\s\")/g,'').replace(/(\"\s)$/g, '').replace(/\\\'/g,"'").replace(/\\"/g,'"')

KD.classes.FSHelper = FSHelper
