func! s:get_working_dirrectory_name()
    return fnamemodify(getcwd(), ':t')
endfunc

func! pdb#common#get_current_file_path()
    return fnamemodify(expand("%"), ":.")
endfunc
