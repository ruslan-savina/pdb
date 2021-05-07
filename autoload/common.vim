func! s:get_working_dirrectory_name()
    return fnamemodify(getcwd(), ':t')
endfunc

func! common#GetDockerContainerName()
    return printf('%s_%s', s:get_working_dirrectory_name(), g:pdb_module_name)
endfunc
