<?php

/* Prevent deletion of actual files on swift */
add_filter('wp_delete_file', '__return_false');

/* Prevent ACF file upload */
add_filter('acf/upload_prefilter', function($errors, $file, $field ){
    $errors[] = __( 'File uploads: Blocked.' );
    return $errors;
}, 10, 3);

/* Always send an error on fileupload */
add_filter('wp_handle_upload_prefilter', function($file) {
    $file['error'] = "File uploads: Blocked.";
    return $file;
});

/* Prefix all files uploaded from this env. */
add_filter('sanitize_file_name', function($filename, $filenameRaw) {
  return "envstage-" . $filename;
}, 50, 2);

/* Force login on this platform */
add_action('init', function(){
  if(defined('WP_CLI') && WP_CLI) {
    return;
  }
  if(!is_user_logged_in() && !is_login()) {
    wp_redirect(home_url('/wp/wp-login.php'));
    exit;
  }
});