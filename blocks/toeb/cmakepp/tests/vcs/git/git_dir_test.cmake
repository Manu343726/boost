function(test)
cd("${test_dir}")
  pushd(repo --create)
  git(init)
  pushd("a/b/c/d" --create)

  git_dir()
  ans(res)
  popd()
  popd()




endfunction()