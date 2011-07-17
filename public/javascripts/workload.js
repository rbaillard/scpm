Ajax.Replacer = Class.create(Ajax.Updater, {
  initialize: function($super, container, url, options) {
    options = options || { };
    options.onComplete = (options.onComplete || Prototype.emptyFunction)
      .wrap(function(proceed, transport, json) {
        $(container).replace(transport.responseText);
        proceed(transport, json);
      })
    $super(container, url, options);
  }
})

function wl_add_line(person_id) {
  $('wl_line_add_form').appear({duration:0.2});
  }

function wl_save_value(line_id, wlweek) {
  new Ajax.Request('/workloads/edit_load?l='+line_id+'&w='+wlweek+'&v='+$(line_id+'_'+wlweek).value, {
    asynchronous:true,
    evalScripts:true,
    onComplete: function(r){
      arr = r.responseText.split(',')
      $(line_id+'_'+wlweek).value = arr[0]
      $('ltotal_' +line_id).innerHTML = arr[1]
      $('ctotal_'  +wlweek).innerHTML = arr[2]
      $('cpercent_'+wlweek).innerHTML = arr[3] + "%"
      if(parseInt(arr[3])>110)
        wl_change_colors(wlweek,"#F00","#FFF");
      else if(parseInt(arr[3])<90)
        wl_change_colors(wlweek,"#F90","#000");
      else
        wl_change_colors(wlweek,"#FFF","#940");
      }
    });
  }

function wl_change_colors(wlweek, background, color) {
  $('cpercent_'+wlweek).style.background  = background;
  $('cpercent_'+wlweek).style.color       = color;
  }

function change_workload(person_id) {
  document.body.style.cursor = 'wait';
  new Ajax.Request('/workloads/change_workload', {
    parameters: { person_id: person_id }
    });
  }

function set_fixed_header() {
  $j('table').fixedHeaderTable({ height: '400', footer: false, fixedColumn: false });
  }
