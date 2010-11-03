

// Hide our code from the global scope
(function($) {

  $(function() {
    var jqconsole = $('.jqconsole');
    var controller;

    function generateVarsTable(vars) {
      var table = $('<table />', {
        "border": "0",
        "cellspacing":"0",
        "cellpadding":"0"
      }).append($('<thead><tr class="head"><th>Variable</th><th>Type</th><th>Value</th></tr></thead>'));
      var count = 0;
      for (var i in vars) {
        var tr = $('<tr />', {
          'class': (count%2 == 0)?'even':'odd'
        });
        tr.append($('<td />').text(i));
        tr.append($('<td />').text(vars[i][1]));
        tr.append($('<td />').text(vars[i][0]));
        table.append(tr);
        count += 1;
      }
      $('.variable-list').empty().append(table);

    }

    function processData(data) {

      controller.continuedPrompt = data.expectingInput || false;

      if (data.error != 0)
      {
          var div = '<div class="error-msg">Snap! Something went wrong.</div>'
          var target = jqconsole
            .find('.jquery-console-prompt-box:last')
            .append(div);
          return true
      }

      if (data.vars) {
        generateVarsTable(data.vars);
      }

      setTimeout(function() {
        MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
      }, 200);

      // match incoming base64 encoded images
      if (data.answer.match(/data:image\/[^;]*;base64,/)) {
        data.answer = data.answer.substring(1, data.answer.length-2);
        data.type = 'img';
      }

      var match;
      if (match = /'(\$.*\$)'/.exec(data.answer)) {
        data.answer = match[1];
      }

      switch (data.type || '') {
        case 'img':
          var img = $('<img />', {
            'class': 'img-plot',
            'src':data.answer
          });

          var target = jqconsole
            .find('.jquery-console-prompt-box:last')
            .append(img);

          img.click( function () {
            var dialog = img.dialog({
              title: 'Plot',
              modal:true,
              width: 850,
              draggable: false,
              resizable: false,
              close: function() {
                dialog.dialog('destroy');
                // put element back where it goes
                target.append(img);

                // dialog leave a bunch of css set on the element
                // clear it all
                img.removeAttr('style');
                controller.scrollToBottom();
              }
            });
            $('.ui-widget-overlay').click(function(e) {
              dialog.dialog('close');
            });
          });
          return true;
        default:
          return data.answer;
      }
    };

    $.ajax({
      cache: false,
      dataType: 'json',
      data: {command: ''},
      type: 'POST',
      url: 'repl/new_command',
    });


    // Returns an object representing the state of the ajax request
    // Has send and cancel functions run by the console emulator
    var ajaxRequest = (function() {
      var state = false;
      var loader = $('<img />').attr('src', '/images/loader.gif');
      var request = false;
      var resultCallback = false;
      return {
        requestRunning: function() {
          return request;
        },
        send: function(line, resultFunc) {
          // Save result callback for use by cancel function
          resultCallback = resultFunc;

          // perform ajax and save reference in case an abort is needed
          request = $.ajax({
            cache: false,
            dataType: 'json',
            data: {command: line},
            type: 'POST',
            url: 'repl/new_command',
            success: function(data) {
              request = false;
              loader.detach();

              resultCallback(processData(data), 'jquery-console-message-success');
            }
          });

          jqconsole.find('.jquery-console-prompt-box:last').append(loader);
        },
        cancel: function() {
          if (request) {
            request.abort();
            request = false;

            loader.detach();
            resultCallback('Command interrupted', 'jquery-console-message-error');
          }
        }
      };
    })();

    controller = jqconsole.console({
      promptLabel: '>>> ',
      continuedPromptLabel: '. . . ',
      commandHandle: ajaxRequest.send,
      cancelHandle: ajaxRequest.cancel,
      autofocus: true,
      animateScroll: true,
      promptHistory: true,
      welcomeMessage: 'Welcome to PyAlpha: Scientific calculation made easy.'
    });

    var help = $('#help-info');
    var sample = $('#sample-scripts');

    $('#help button').button().click(function(){
      help.dialog({
        title: "PyAlpha Help",
        modal: true,
        resizable: false,
        width: $(window).width()-70,
        height: $(window).height()-70
      });
    });

    $('#samples button').button().click(function(){
      sample.dialog({
        title: "PyAlpha Samples",
        modal: true,
        resizable: false,
        width: $(window).width()-70,
        height: $(window).height()-70
      });
    });

    $(window).resize(function() {
      var h = $(window).height();
      help.height(h-100);
      sample.height(h-100);
    });


    // Make the cursor blink
    (function() {
      var trans = false;
      setInterval(function() {
        trans = !trans;
        $('.jquery-console-cursor').css('background-color', trans?'transparent':'');
      }, 750);
    })();

    (function() {
      function runCommands(com) {
        var i = 0;
        var interval = setInterval(function() {
          if (!ajaxRequest.requestRunning()) {
            if (i < com.length) {
              controller.promptText(com[i]);
              controller.commandTrigger();
              i += 1;
            }
            else {
              controller.promptText('');
              clearInterval(interval);
              jqconsole.click();
            }
          }
        }, 100);
      }

      var samples = [
        {
          title: "Simple Fractions",
          commands: [
            "x = Symbol('x')",
            "pretty(x/2)"
          ]
        },
        {
          title: "Find Polynomial Root",
          commands: [
            "x=Symbol('x')",
            "f = x**3 + 2*x**2+4*x",
            "pretty(f)",
            "pretty(solve(Eq(f, 0), x))"
          ]
        },
        {
          title: "Solve differention Equation",
          commands: [
            "x = Symbol('x')",
            "g = Function('g')",
            "h = Derivative(g(x), x, x) + 9*g(x) + 1",
            "pretty(h)",
            "pretty(dsolve(Eq(h, 1), g(x)))"
          ]
        },
        {
          title: "Graphing Samples",
          commands: [
            "x = linspace(0, 10*pi, 200)",
            "a = imgPlot()",
            "plt.plot(x, x-average(x))",
            "plt.plot(x, sin(x))",
            "plt.plot(x, cos(x))",
            "plt.plot(x, 5*sin(x)+12)",
            "plt.plot(x, sin(x)-x + average(x))",
            "plt.plot(x, ((x-15)**2)/10-15)",
            "a.getPlot()"
          ]
        }
      ];
      var target = $('#sample-scripts');

      for (var i in samples) {
        var list = $('<ul />');
        for (var j in samples[i].commands) {
          var com = samples[i].commands[j];
          list.append($('<li />').text(com));
        }
        target
        .append(samples[i].title)
        .append(list)
        .append(
          $('<button>')
          .text('Run')
          .click(samples[i].commands, function(e) {
            runCommands(e.data);
            target.dialog('close');
          })
        )
        .append($('<br />'));
      }

    })();
  });
})(jQuery);

