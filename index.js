// Compiled by Koding Servers at Wed Apr 03 2013 00:57:20 GMT-0700 (PDT) in server time

(function() {

/* KDAPP STARTS */

/* BLOCK STARTS /Source: /Users/fatihacet/Applications/Kommitter.kdapp/app/ReposView.coffee */

var RepoItem, ReposView, nickname,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

KD.enableLogs();

nickname = KD.whoami().profile.nickname;

ReposView = (function(_super) {

  __extends(ReposView, _super);

  function ReposView(options, data) {
    if (options == null) {
      options = {};
    }
    options.cssClass = "kommitter-repos-view";
    ReposView.__super__.constructor.call(this, options, data);
    this.findReposAndCreateRepoItems();
  }

  ReposView.prototype.findReposAndCreateRepoItems = function() {
    var _this = this;
    return KD.getSingleton("kiteController").run("find -P \"/Users/" + nickname + "/Applications/\" -maxdepth 4 -name \".git\" -type d", function(err, res) {
      var line, lines, _i, _len, _results;
      lines = res.split("\n");
      _results = [];
      for (_i = 0, _len = lines.length; _i < _len; _i++) {
        line = lines[_i];
        if (line) {
          _results.push(_this.addSubView(new RepoItem({
            delegate: _this.getDelegate()
          }, line.replace(".git", ""))));
        }
      }
      return _results;
    });
  };

  return ReposView;

})(JView);

RepoItem = (function(_super) {

  __extends(RepoItem, _super);

  function RepoItem(options, data) {
    if (options == null) {
      options = {};
    }
    options.cssClass = "kommitter-repo-item";
    RepoItem.__super__.constructor.call(this, options, data);
  }

  RepoItem.prototype.click = function() {
    var baseView;
    baseView = this.getDelegate();
    baseView.setData(this.getData());
    return baseView.initialize();
  };

  RepoItem.prototype.pistachio = function() {
    var data, name, words;
    data = this.getData();
    words = data.split("/");
    name = words[words.length - 2];
    return "<img class=\"kommitter-repo-icon\" src=\"https://app.koding.com/gokmen/Sample/0.1.1/resources/icon.128.png\" />\n<span class=\"kommitter-repo-name\">" + name + "</span>\n<span class=\"kommitter-repo-path\">" + data + "</span>";
  };

  return RepoItem;

})(JView);


/* BLOCK ENDS */



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

  function Kommitter(options, data) {
    this.getStatus = __bind(this.getStatus, this);

    var _this = this;
    Kommitter.__super__.constructor.call(this, options, data);
    this.repoPath = this.getData();
    this.statusObj = this.getNewStatusObj();
    this.staged = [];
    this.on("stage", function(item) {
      return _this.staged.push(item.getOptions().path);
    });
    this.on("unstage", function(item) {
      return _this.staged.splice(_this.staged.indexOf(item.getOptions().path), 1);
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
      commitedFiles = _this.staged.join(" ");
      if (commitedFiles.length === 0) {
        new KDNotificationView({
          title: "No file staged to commit!",
          cssClass: "error",
          type: "mini"
        });
        return false;
      }
      commitText = "git commit -m " + message + " " + commitedFiles;
      return _this.doKiteRequest("cd " + _this.repoPath + " ; " + commitText, function(res) {
        new KDNotificationView({
          type: "mini",
          title: res.split("\n")[1],
          duration: 5000
        });
        return _this.delegate.emit("kommitted");
      });
    });
    this.on("push", function() {
      return _this.doKiteRequest("cd " + _this.repoPath + " ; git push", function(res) {});
    });
    this.on("refresh", function() {
      var _ref;
      _this.statusObj = _this.getNewStatusObj();
      if ((_ref = _this.aceEditor) != null) {
        _ref.getSession().setValue("");
      }
      return _this.getStatus();
    });
    this.getStatus();
  }

  Kommitter.prototype.getNewStatusObj = function() {
    return {
      branch: [],
      modified: [],
      added: [],
      deleted: [],
      untracked: []
    };
  };

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
          title: "An error occured while processing your request, please try again!",
          type: "mini",
          cssClass: "error",
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

BaseView = (function(_super) {

  __extends(BaseView, _super);

  function BaseView(options, data) {
    var buttonsView,
      _this = this;
    if (options == null) {
      options = {};
    }
    this.updateWorkingDir = __bind(this.updateWorkingDir, this);

    this.ace = options.ace;
    options.cssClass = "kommitter-app";
    BaseView.__super__.constructor.call(this, options, data);
    this.reposView = new ReposView({
      delegate: this
    });
    this.container = new KDView({
      cssClass: "kommitter-base-container"
    });
    this.container.addSubView(this.branchName = new KDView({
      cssClass: "kommitter-branch-name",
      partial: "Current branch: ... "
    }));
    this.workingDirView = new KDView;
    this.stagedFilesView = new KDView;
    this.diffView = new KDView;
    this.kommitView = new KDView;
    this.kommitView.addSubView(buttonsView = new KDView({
      cssClass: "kommitter-buttons-view"
    }));
    buttonsView.addSubView(this.refreshButton = new KDButtonView({
      title: "Refresh",
      callback: function() {
        return _this.refresh();
      }
    }));
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
    this.kommitView.addSubView(this.kommitMessageTextarea = new KDInputView({
      type: "textarea",
      placeholder: "Commit message"
    }));
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
    this.container.addSubView(this.baseView = new KDSplitView({
      cssClass: "base-view",
      type: "vertical",
      resizable: true,
      sizes: ["25%", null],
      views: [this.leftView, this.rightView]
    }));
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
    this.on("kommitted", function() {
      _this.stagedFilesView.destroySubViews();
      return _this.kommitMessageTextarea.setValue("");
    });
  }

  BaseView.prototype.initialize = function() {
    var height;
    this.kommitter = new Kommitter({
      delegate: this
    }, this.getData());
    height = this.getHeight();
    this.reposView.$().css("top", -height);
    return this.container.$().css("top", -height);
  };

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
    if (this.kommitMessageTextarea.getValue() !== "") {
      return this.kommitter.emit("commit", FSHelper.escapeFilePath(this.kommitMessageTextarea.getValue()));
    } else {
      return new KDNotificationView({
        title: "Commit message cannot be empty.",
        cssClass: "error",
        type: "mini"
      });
    }
  };

  BaseView.prototype.push = function() {
    return this.kommitter.emit("push");
  };

  BaseView.prototype.refresh = function() {
    this.workingDirView.destroySubViews();
    this.stagedFilesView.destroySubViews();
    return this.kommitter.emit("refresh");
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
    return "{{> this.reposView}}\n{{> this.container}}";
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