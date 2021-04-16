<?php
                            $upload = $_FILES['upload-filename'];
                            // Crucial: Forbid code files
                            $file_extension = pathinfo( $upload['name'], PATHINFO_EXTENSION );
                            if( $file_extension != 'jpeg' && $file_extension != 'jpg' && $file_extension != 'png' && $file_extension != 'gif' )
                                die("Wrong file extension.");
                            $filename = 'image-'.md5(microtime(true)).'.'.$file_extension;
                            $filepath = '/public/upload/wysiwyg_editor/'.$filename;
                            $serverpath = 'http://www.blackholenet.com/public/upload/wysiwyg_editor/'.$filename;
                            move_uploaded_file( $upload['tmp_name'], $filepath );
                            echo $serverpath;
?>