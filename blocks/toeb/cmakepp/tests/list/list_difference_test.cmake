function(test)

  set(lstA a a b c d e e)
  set(lstB a b c f)


  list_difference(lstA lstB)
  ans(res)
  assert(${res} EQUALS d e)




  set(lstA a b c d e)
  set(lstB)

  list_difference(lstA lstB)
  ans(res)
  assert(${res} EQUALS a b c d e)


  set(lstA)
  set(lstB a b c d e)

  list_difference(lstA lstB)
  ans(res)
  assert(${res} ISNULL)

 
  set(lstA)
  set(lstB)

  list_difference(lstA lstB)
  ans(res)
  assert(${res} ISNULL)


  


endfunction()