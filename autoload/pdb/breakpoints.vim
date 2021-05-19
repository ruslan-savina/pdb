let g:breakpoints_data = {}

func! s:sign_place(file_path, line_number)
    return sign_place(
    \   0, 'Breakpoint', 'Breakpoint', a:file_path, 
    \   {'lnum': a:line_number, 'priority': 1000}
    \)
endfunc

func! s:sign_unplace(id, file_path)
    call sign_unplace(
    \    'Breakpoint', {'buffer': a:file_path, 'id': a:id}
    \)
endfunc

func! s:sign_get_placed(file_path)
    return sign_getplaced(a:file_path, {'group': 'Breakpoint'})[0].signs
endfunc

func! s:breakpoint_new(line_number, condition)
    let result = {
    \   'id': v:null,
    \   'line_number': a:line_number,
    \   'condition': a:condition,
    \}
    return result
endfunc

func! s:breakpoint_add(file_path, line_number, condition)
    let breakpoints = get(g:breakpoints_data, a:file_path, [])
    if empty(breakpoints)
        let g:breakpoints_data[a:file_path] = breakpoints
    endif
    let breakpoint = s:breakpoint_new(a:line_number, a:condition)
    call add(breakpoints, breakpoint)
endfunc

func! s:breakpoint_delete(file_path, line_number)
    let breakpoints = get(g:breakpoints_data, a:file_path)
    if !empty(breakpoints)
        for breakpoint in breakpoints
            if breakpoint.line_number == a:line_number
                call remove(breakpoints, index(breakpoints, breakpoint))
                if len(breakpoints) == 0
                    call remove(g:breakpoints_data, a:file_path)
                endif
            endif
        endfor
    endif
endfunc

func! s:breakpoint_save_data()
    let data = {}
    for [file_path, breakpoints] in items(g:breakpoints_data)
        let breakpoints_data = []
        for breakpoint in breakpoints
            let breakpoint_data = [breakpoint.line_number]
            if !empty(breakpoint.condition)
                call add(breakpoint_data, breakpoint.condition)
            endif
            call add(breakpoints_data, breakpoint_data)
        endfor
        let data[file_path] = breakpoints_data
    endfor
    call writefile(
    \   [string(data)], g:pdb_breakpoints_file_name
    \)
endfunc

func! s:breakpoint_load_data()
    if !file_readable(g:pdb_breakpoints_file_name)
        return
    endif
    let lines = readfile(g:pdb_breakpoints_file_name)
    if empty(lines)
        return
    endif
    execute "let data = " . lines[0]
    for [file_path, breakpoints_data] in items(data)
        let breakpoints = []
        let g:breakpoints_data[file_path] = breakpoints
        for breakpoint_data in breakpoints_data
            let line_number = v:null
            let condition = ''
            let line_number = breakpoint_data[0]
            if len(breakpoint_data) == 2
                let condition = breakpoint_data[1]
            endif
            let breakpoint = s:breakpoint_new(line_number, condition)
            call add(breakpoints, breakpoint)
        endfor
    endfor
endfunc

func! s:breakpoint_update_data(file_path)
    let breakpoint_ids = []
    let breakpoints = get(g:breakpoints_data, a:file_path, [])
    for breakpoint in breakpoints
        if empty(breakpoint.id)
            let breakpoint.id = s:sign_place(a:file_path, breakpoint.line_number)
        endif
        call add(breakpoint_ids, breakpoint.id) 
    endfor

    let lines_count = line('$')
    let signs = s:sign_get_placed(a:file_path)
    for sign in signs
        if sign.lnum > lines_count || index(breakpoint_ids, sign.id) == -1
            call s:sign_unplace(sign.id, a:file_path)
        else
            for breakpoint in breakpoints
                if breakpoint.id == sign.id
                    let breakpoint.line_number = sign.lnum
                endif
            endfor
        endif
    endfor
endfunc

func! s:quickfix_update()
    let items = []
    for [file_path, breakpoints] in items(g:breakpoints_data)
        for breakpoint in breakpoints
            let item = {
            \   'filename': fnamemodify(file_path, ':p'),
            \   'lnum': breakpoint.line_number,
            \   'text': breakpoint.condition,
            \   }
            call add(items, item)
        endfor
    endfor
    call setqflist(items, 'r')
endfunc

func! pdb#breakpoints#add(condition)
    let file_path = pdb#common#get_current_file_path()
    let current_line = line('.')
    call s:breakpoint_delete(file_path, current_line)
    call s:breakpoint_add(file_path, current_line, a:condition)
    call s:breakpoint_update_data(file_path)
    call s:breakpoint_save_data()
    call s:quickfix_update()
endfunc

func! pdb#breakpoints#add_conditional()
    let condition = input("Condition: ")
    call pdb#breakpoints#add(condition)
endfunc

func! pdb#breakpoints#delete()
    let file_path = pdb#common#get_current_file_path()
    call s:breakpoint_delete(file_path, line('.'))
    call s:breakpoint_update_data(file_path)
    call s:breakpoint_save_data()
    call s:quickfix_update()
endfunc

func! pdb#breakpoints#delete_in_file()
    let file_path = pdb#common#get_current_file_path()
    call remove(g:breakpoints_data, file_path)
    call s:breakpoint_update_data(file_path)
    call s:breakpoint_save_data()
    call s:quickfix_update()
endfunc

func! pdb#breakpoints#delete_all()
    let g:breakpoints_data = {}
    call sign_unplace('Breakpoint')
    call s:breakpoint_save_data()
    call s:quickfix_update()
endfunc

func! pdb#breakpoints#list()
    call s:quickfix_update()
    copen
endfunc

func! pdb#breakpoints#init()
    call s:breakpoint_load_data()
endfunc

func! pdb#breakpoints#buf_read()
    let file_path = pdb#common#get_current_file_path()
    call s:breakpoint_update_data(file_path)
endfunc

func! pdb#breakpoints#buf_write()
    let file_path = pdb#common#get_current_file_path()
    call s:breakpoint_update_data(file_path)
    call s:breakpoint_save_data()
    call s:quickfix_update()
endfunc
