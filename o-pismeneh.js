$(function($){
    /**
     * Toggles expanded and collapsed state of a paragraph or h3 in a column in the table
     */
    $('.exlapse').click(function(e) {
        // get all elements with this button's last class
        let classes = $(e.target).attr('class').split(/\s+/)
        let clss = classes[classes.length-1]

        $(`td.${clss},th.${clss}`).each(function() {
            if($('p', this).hasClass('expand')) {
                $('p,h3', this).removeClass('expand').addClass('collapse')
                $(this).attr({width: '2rem'})
            }
            else {
                $('p,h3', this).removeClass('collapse').addClass('expand')
                $(this).attr({width: '40rem'})
            }
        })
    });

    /**
     * Moves a column to the left
     */
    $('.to-left').click(function(e) {
        // get all elements with this button's last class
        let classes = $(e.target).attr('class').split(/\s+/)
        let clss = classes[classes.length-1]

        $(`td.${clss},th.${clss}`).each(function() {
            // get the sibling before this element
            let left = $(this).prev()
            $(this).insertBefore(left)
        })
    });

    /**
     * Moves a column to the right
     */
    $('.to-right').click(function(e) {
        // get all elements with this button's last class
        let classes = $(e.target).attr('class').split(/\s+/)
        let clss = classes[classes.length-1]

        $(`td.${clss},th.${clss}`).each(function() {
            // get the sibling after this element
            let right = $(this).next()
            $(this).insertAfter(right)
        })
    });

    /**
     * Switches font according to the selected fornt
     */
    $('select').change(function() {
        let clss = $(this).attr('class')
        let newClass = $(this).val()
        $(`td.${clss},th.${clss}`).each(function() {
            $(this).removeClass('normal cu').addClass(newClass)
        })
    });

    /**
     *  Change initially selected font depending on the language
     */
    $('select[lang="cu"]').val('cu')
    $('select[lang!="cu"]').val('normal')
});