func! s:get_working_dirrectory_name()
    return fnamemodify(getcwd(), ':t')
endfunc

func! pdb#common#get_docker_container_name()
    return printf('%s_%s', s:get_working_dirrectory_name(), g:pdb_module_name)
endfunc

func! pdb#common#get_current_file_path()
    return fnamemodify(expand("%"), ":~:.")
endfunc
