execute 'source ' . expand('%:p:h') . '/t/_common/test_helpers.vim'

call vspec#hint({'scope': 'test_helpers#scope()'})



describe '_HandleLocalDict_'

  it 'should preserve/refer/set/recover script local variable with dict'
    let local_name = 's:test_helpers'
    let local_default = {'foo': 'bar', 'baz': ['qux']}
    let local_changed = {'foo': 'bar-bar', 'baz': ['qux', 'qux-qux']}
    call Set(local_name, local_default)

    call _HandleLocalDict_(local_name, 1)

    Expect _HandleLocalDict_(local_name, 'foo') == 'bar'
    Expect _HandleLocalDict_(local_name, 'baz') == ['qux']
    Expect Ref(local_name) == local_default

    call _HandleLocalDict_(local_name, local_changed)

    Expect _HandleLocalDict_(local_name, 'foo') == 'bar-bar'
    Expect _HandleLocalDict_(local_name, 'baz') == ['qux', 'qux-qux']
    Expect Ref(local_name) == local_changed

    call _HandleLocalDict_(local_name, 0)

    Expect Ref(local_name) == local_default

    let stack_name = 'foobarbazquz_stack'
    call _HandleLocalDict_(local_name, 1, stack_name)

    Expect _HandleLocalDict_(local_name, 'foo', stack_name) == 'bar'
    Expect _HandleLocalDict_(local_name, 'baz', stack_name) == ['qux']
    Expect Ref(local_name) == local_default

    call _HandleLocalDict_(local_name, local_changed, stack_name)

    Expect _HandleLocalDict_(local_name, 'foo', stack_name) == 'bar-bar'
    Expect _HandleLocalDict_(local_name, 'baz', stack_name) == ['qux', 'qux-qux']
    Expect Ref(local_name) == local_changed

    call _HandleLocalDict_(local_name, 0, stack_name)

    Expect Ref(local_name) == local_default
  end

end


describe '_Reg_'

  it 'should register/refer/remove value to global variable with prefix'
    let prefix = '__'
    let pack = {'foo': 'bar', 'baz': ['qux']}

    Expect get(g:, prefix.'foo', '') == ''
    Expect get(g:, prefix.'baz', '') == ''

    call _Reg_(prefix, pack)

    Expect get(g:, prefix.'foo', '') == 'bar'
    Expect get(g:, prefix.'baz', '') == ['qux']

    Expect _Reg_(prefix, 'foo') == 'bar'
    Expect _Reg_(prefix, 'baz') == ['qux']

    call _Reg_(prefix, 0)

    Expect get(g:, prefix.'foo', '') == ''
    Expect get(g:, prefix.'baz', '') == ''
  end

end


describe '_Stash_'

  it 'should preserve/recover global variables that name start with prefix'
    let prefix = '__t__'

    let g:__t__foo = 'baz'
    let g:__t__bar = ['qux']

    call _Stash_(prefix)

    Expect g:__t__foo == 'baz'
    Expect g:__t__bar == ['qux']

    let g:__t__foo = 'baz-baz'
    let g:__t__bar = ['qux', 'qux-qux']

    call _Stash_(0)

    Expect g:__t__foo == 'baz'
    Expect g:__t__bar == ['qux']

    let stash_name = 'foobarbazqux_stash'
    call _Stash_(prefix, stash_name)

    let g:__t__foo = 'baz-baz'
    let g:__t__bar = ['qux', 'qux-qux']

    Expect has_key(g:, stash_name) to_be_true

    call _Stash_(0, stash_name)

    Expect g:__t__foo == 'baz'
    Expect g:__t__bar == ['qux']
  end

end

