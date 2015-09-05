/**
 * Created by rolly_000 on 7/16/2015.
 */

$(document).ready(function() {

    // Store variables

    var accordion_head = $('.rp_impersonate_accordion > li > a'),
        accordion_body = $('.rp_impersonate_accordion li > .sub-menu');

    // Open the last tab on load

    accordion_body.last().addClass('active').slideToggle('normal');

    // Click function

    accordion_head.on('click', function(event) {

        // Disable header links

        event.preventDefault();

        // Show and hide the tabs on click

        if ($(this).attr('class') != 'active'){
            accordion_body.slideUp('normal');
            $(this).next().stop(true,true).slideToggle('normal');
            accordion_head.removeClass('active');
            $(this).addClass('active');
        }

    });

});