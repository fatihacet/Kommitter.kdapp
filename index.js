// Compiled by Koding Servers at Sun Jan 13 2013 23:17:36 GMT-0800 (PST) in server time

(function() {

/* KDAPP STARTS */

/* BLOCK STARTS /Source: /Users/fatihacet/Applications/Kommitter.kdapp/app/FileItem.coffee */

var FileItem,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

FileItem = (function(_super) {

  __extends(FileItem, _super);

  function FileItem(options) {
    if (options == null) {
      options = {};
    }
    this.click = __bind(this.click, this);

    options.cssClass = "kommitter-file-item";
    FileItem.__super__.constructor.call(this, options);
    this.type = this.getOptions().type;
    this.path = this.getOptions().path;
    this.isStaged = this.type === "added";
  }

  FileItem.prototype.getIcon = function(type) {
    return "<div class=\"kommitter-icon kommitter-icon-" + type + "\"></div>";
  };

  FileItem.prototype.getStagedStatus = function() {
    return this.isStaged;
  };

  FileItem.prototype.partial = function() {
    return "" + (this.getIcon(this.getOptions().type)) + (this.getOptions().path);
  };

  FileItem.prototype.click = function(e) {
    if ($(e.target).hasClass('kommitter-icon')) {
      this.isStaged = !this.isStaged;
      return this.getDelegate().emit("stageOrUnstage", this);
    } else {
      return this.getDelegate().emit("diff", this.path);
    }
  };

  return FileItem;

})(KDListItemView);


/* BLOCK ENDS */



/* BLOCK STARTS /Source: /Users/fatihacet/Applications/Kommitter.kdapp/app/Kommitter.coffee */

var Kommitter,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Kommitter = (function(_super) {

  __extends(Kommitter, _super);

  function Kommitter(repoPath, parent) {
    this.getStatus = __bind(this.getStatus, this);

    var _this = this;
    Kommitter.__super__.constructor.apply(this, arguments);
    this.delegate = parent;
    this.repoPath = repoPath;
    this.statusObj = {
      branch: [],
      modified: [],
      added: [],
      deleted: [],
      untracked: []
    };
    this.staged = [];
    this.on("stage", function(item) {
      return _this.staged.push(item.getOptions().path);
    });
    this.on("unstage", function(item) {
      var arr, i, len, target, _results;
      arr = _this.staged;
      target = item.getOptions().path;
      i = 0;
      len = arr.length;
      _results = [];
      while (i < len) {
        if (arr[i] === target) {
          arr.splice(i, 1);
        }
        _results.push(i++);
      }
      return _results;
    });
    this.on("diff", function(path) {
      return _this.doKiteRequest("cd " + _this.repoPath + " ; git diff " + path, function(res) {
        _this.aceEditor = _this.delegate.ace.edit(_this.delegate.diffView.domElement[0]);
        _this.aceEditor.setTheme("ace/theme/monokai");
        _this.aceEditor.getSession().setMode("ace/mode/diff");
        _this.aceEditor.setReadOnly(true);
        return _this.aceEditor.getSession().setValue(res);
      });
    });
    this.on("commit", function(message) {
      var commitText, commitedFiles;
      commitedFiles = _this.staged.join('');
      commitText = "git commit -m " + message + " " + commitedFiles;
      return _this.doKiteRequest("cd " + _this.repoPath + " ; " + commitText, function(res) {
        return new KDNotificationView({
          type: 'mini',
          title: res.split('\n')[1],
          duration: 5000
        });
      });
    });
    this.on("push", function() {
      return _this.doKiteRequest("cd " + _this.repoPath + " ; git push", function(res) {});
    });
    this.getStatus();
  }

  Kommitter.prototype.getStatus = function(repoPath) {
    var _this = this;
    return this.doKiteRequest("cd " + (FSHelper.escapeFilePath(this.repoPath)) + " ; git branch ; git status -s", function(res) {
      _this.parseOutput(res);
      return _this.getDelegate().emit("status", _this.statusObj);
    });
  };

  Kommitter.prototype.statusKeys = {
    branch: "* ",
    modified: " M",
    added: "A ",
    deleted: " D",
    untracked: "??"
  };

  Kommitter.prototype.parseOutput = function(res) {
    var currentKey, key, keys, result, results, _i, _len, _results;
    results = res.split("\n");
    keys = this.statusKeys;
    _results = [];
    for (_i = 0, _len = results.length; _i < _len; _i++) {
      result = results[_i];
      _results.push((function() {
        var _results1;
        _results1 = [];
        for (key in this.statusKeys) {
          currentKey = this.statusKeys[key];
          if (result.indexOf(currentKey) === 0) {
            _results1.push(this.statusObj[key].push(result.split(currentKey)[1]));
          } else {
            _results1.push(void 0);
          }
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  Kommitter.prototype.doKiteRequest = function(command, callback) {
    var _this = this;
    return KD.getSingleton('kiteController').run(command, function(err, res) {
      if (!err) {
        if (callback) {
          return callback(res);
        }
      } else {
        return new KDNotificationView({
          title: "An error occured while processing your request, try again please!",
          type: "mini",
          duration: 3000
        });
      }
    });
  };

  return Kommitter;

})(KDObject);


/* BLOCK ENDS */



/* BLOCK STARTS /Source: /Users/fatihacet/Applications/Kommitter.kdapp/app/BaseView.coffee */

var BaseView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

KD.enableLogs();

BaseView = (function(_super) {

  __extends(BaseView, _super);

  function BaseView(options) {
    var buttonsView,
      _this = this;
    if (options == null) {
      options = {};
    }
    this.updateWorkingDir = __bind(this.updateWorkingDir, this);

    this.ace = options.ace;
    options.cssClass = "kommitter-app";
    BaseView.__super__.constructor.call(this, options);
    this.branchName = new KDView({
      cssClass: "kommitter-branch-name",
      partial: "Current branch: ... "
    });
    this.workingDirView = new KDView;
    this.stagedFilesView = new KDView;
    this.diffView = new KDView;
    buttonsView = new KDView;
    buttonsView.addSubView(this.commitButton = new KDButtonView({
      title: "Commit",
      callback: function() {
        return _this.commit();
      }
    }));
    buttonsView.addSubView(this.pushButton = new KDButtonView({
      title: "Push",
      callback: function() {
        return _this.push();
      }
    }));
    this.kommitMessageTextarea = new KDInputView({
      type: "textarea",
      placeholder: "Commit message"
    });
    this.kommitView = new KDSplitView({
      type: "vertical",
      resizable: false,
      sizes: [100, null],
      views: [buttonsView, this.kommitMessageTextarea]
    });
    this.leftView = new KDSplitView({
      cssClass: "left-view",
      type: "horizontal",
      resizable: true,
      sizes: ["75%", null],
      views: [this.workingDirView, this.stagedFilesView]
    });
    this.rightView = new KDSplitView({
      cssClass: "left-view",
      type: "horizontal",
      resizable: true,
      sizes: ["75%", null],
      views: [this.diffView, this.kommitView]
    });
    this.baseView = new KDSplitView({
      cssClass: "base-view",
      type: "vertical",
      resizable: true,
      sizes: ["25%", null],
      views: [this.leftView, this.rightView]
    });
    this.kommitter = new Kommitter("GitHub/geneJS/", this);
    this.on("status", function(res) {
      _this.updateBranchName(res.branch[0]);
      delete res.branch;
      return _this.updateWorkingDir(res);
    });
    this.on("updateStatus", function(res) {
      _this.removeLeftPanelSubViews();
      return _this.updateWorkingDir(res);
    });
    this.on("stageOrUnstage", function(item) {
      var eventName;
      eventName = item.getStagedStatus() ? "stage" : "unstage";
      _this[eventName](item);
      return _this.kommitter.emit(eventName, item);
    });
    this.on("diff", function(path) {
      return _this.kommitter.emit("diff", path);
    });
  }

  BaseView.prototype.updateBranchName = function(branchName) {
    return this.branchName.updatePartial("Current branch: " + branchName);
  };

  BaseView.prototype.stage = function(item) {
    var initialType, newItem;
    this.workingDirView.removeSubView(item);
    initialType = item.getOptions().type;
    newItem = new FileItem({
      delegate: this,
      path: item.getOptions().path,
      type: "added",
      oldType: initialType
    });
    return this.stagedFilesView.addSubView(newItem);
  };

  BaseView.prototype.unstage = function(item) {
    var newItem;
    this.stagedFilesView.removeSubView(item);
    newItem = new FileItem({
      delegate: this,
      path: item.getOptions().path,
      type: item.getOptions().oldType
    });
    return this.workingDirView.addSubView(newItem);
  };

  BaseView.prototype.commit = function() {
    return this.kommitter.emit("commit", FSHelper.escapeFilePath(this.kommitMessageTextarea.getValue()));
  };

  BaseView.prototype.push = function() {
    return this.kommitter.emit("push");
  };

  BaseView.prototype.updateWorkingDir = function(files) {
    var file, fileList, _results;
    _results = [];
    for (fileList in files) {
      _results.push((function() {
        var _i, _len, _ref, _results1,
          _this = this;
        _ref = files[fileList];
        _results1 = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          file = _ref[_i];
          _results1.push((function(file) {
            var item, target;
            item = new FileItem({
              delegate: _this,
              path: file,
              type: fileList
            });
            target = fileList === "added" ? _this.stagedFilesView : _this.workingDirView;
            return target.addSubView(item);
          })(file));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  BaseView.prototype.pistachio = function() {
    return "{{> this.branchName}}\n{{> this.baseView}}";
  };

  return BaseView;

})(JView);


/* BLOCK ENDS */



/* BLOCK STARTS /Source: /Users/fatihacet/Applications/Kommitter.kdapp/index.coffee */


(function() {
  return require(["ace/ace"], function(Ace) {
    return appView.addSubView(new BaseView({
      ace: Ace
    }));
  });
})();


/* BLOCK ENDS */

/* KDAPP ENDS */

}).call();