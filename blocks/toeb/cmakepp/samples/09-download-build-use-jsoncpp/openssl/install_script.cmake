function(__ proj pack)
set(uri "https://www.openssl.org/source/openssl-1.0.2.tar.gz")
message(STATUS "installing openssl - ${uri}")
assign(success = proj.install("${uri}"))
endfunction()