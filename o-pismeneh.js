//Add functionality to buttons and links to navigate within the document, hide
//and show columns, etc.
$(function($){
    /**
     * Toggles expanded and collapsed state of a paragraph or h3 in a column in
     * the table.
     */
    $('#xapli .exlapse').click(function(e) {
        // get all elements with this button's last class
        let classes = $(e.target).attr('class').split(/\s+/)
        // get the last class which is the same for all the cells in the
        // collumn and does not change ever.
        let clss = classes[classes.length-1]

        $(`td.${clss},th.${clss}`).each(function() {
            if($(this).hasClass('expand')) {
                $('p,h3', this).removeClass('expand').addClass('collapse')
                $(this).removeClass('expand').addClass('collapse')
            }
            else {
                $('p,h3', this).removeClass('collapse').addClass('expand')
                $(this).removeClass('collapse').addClass('expand')
            }
        })
    });

    /**
     * Moves a column to the left.
     */
    $('#xapli .to-left').click(function(e) {
        // get all elements with this button's last class
        let classes = $(e.target).attr('class').split(/\s+/)
        let clss = classes[classes.length-1]

        $(`td.${clss},th.${clss}`).each(function() {
            // get the first from right to left visible sibling before this element
            let left = $(this).prevAll(':visible').get(0)
            $(this).insertBefore(left)
        })
    });

    /**
     * Moves a column to the right.
     */
    $('#xapli .to-right').click(function(e) {
        // get all elements with this button's last class
        let classes = $(e.target).attr('class').split(/\s+/)
        let clss = classes[classes.length-1]

        $(`td.${clss},th.${clss}`).each(function() {
            // get the first visible sibling after this element
            let right = $(this).nextAll(':visible').get(0)
            $(this).insertAfter(right)
        })
    });

    /**
     * Switches font according to the selected class.
     */
    $('#xapli select').change(function() {
        let clss = $(this).attr('class')
        let newClass = $(this).val()
        $(`td.${clss},th.${clss}`).each(function() {
            $(this).removeClass('normal cu').addClass(newClass)
        })
    });

    /**
     *  Change initially selected font depending on the language.
     */
    $('#xapli select[lang="cu"]').val('cu').trigger('change')
    $('#xapli select[lang!="cu"]').val('normal').trigger('change')

    /**
     * Hide all columns which buttons are not primary. Make it visible for the
     * user. Then attach the toggling functionality to all buttons.
     * For some reason this approach stopped working, so hiding the columns initially in HTML, not here.
     */
    $('#column_buttons button').each(function() {
        let button = $(this);
        let clss = button.attr('for')
       /*
        alert($(this).attr('class'))
        if(!button.attr('class').match(/primary/)) {
            $(`th.${clss},td.${clss}`).toggle('slow')
        }
       */
        button.click(function() {
            if(button.attr('class').match(/primary/)) {
                button.removeClass('primary')
            }
            else {
                button.addClass('primary')
            }
            $(`th.${clss},td.${clss}`).toggle('slow')
        })
    })

    /**
     * Fix scrolling between endnotes and targets.
     */
    $('a[href^="\#"]').click(function(e) {
        e.preventDefault()
        let id = $($(this).attr("href"))
        let top = id.offset().top
        let header_height = $('header').outerHeight() + 16
        let scroll = 300, fade = 300, delay = 500

        $('html,body').animate({scrollTop: top - header_height }, scroll)
        if(id.attr('id').match(/^n_/)) {
            id.parent().delay(delay).fadeOut(fade).fadeIn(fade)
            id.delay(delay + fade).fadeOut(fade).fadeIn(fade)
        }
        else {
            id.parent().parent().delay(delay).fadeOut(fade).fadeIn(fade)
            id.delay(delay + fade).fadeOut(fade).fadeIn(fade)
        }
    });

    /**
     * Prevent most key combinations on the page as well as dragging, selecting and context menu
    document.onkeydown = function(e) {
      if(event.ctrlKey || event.shiftKey) {
        return false
      }
    }
    document.oncontextmenu = document.ondragstart = document.onselectstart = function() { return false;}
     */
});
