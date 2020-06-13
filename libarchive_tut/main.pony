use "path:C:/Users/z124t/Downloads/liblzma/bin_x86-64"
use "path:C:/Users/z124t/Downloads/bzip2-master/build/Release"
use "path:C:/Users/z124t/Downloads/zlib-1.2.11/build/Release"
use "path:C:/Users/z124t/Downloads/libarchive/lib"
use "lib:liblzma"
use "lib:bz2"
use "lib:zlibstatic"
use "lib:archive_static"
use "files"
use "assert"
use @archive_read_new[Pointer[_Archive]]()
use @archive_write_disk_new[Pointer[_Archive]]()
use @archive_read_support_compression_gzip[I32](a: Pointer[_Archive])
use @archive_read_support_compression_lzip[I32](a: Pointer[_Archive])
use @archive_read_support_compression_bzip2[I32](a: Pointer[_Archive])
use @archive_read_support_format_all[I32](a: Pointer[_Archive])
use @archive_read_open_filename[I32](a: Pointer[_Archive],
      filename: Pointer[U8] tag, block_size: USize)
use @archive_read_next_header[I32](a: Pointer[_Archive], b: Pointer[Pointer[_Archive]])
use @archive_read_free[None](a: Pointer[_Archive])
use @archive_entry_pathname[Pointer[U8]](a: Pointer[_Archive])
use @archive_error_string[Pointer[U8]](a: Pointer[_Archive])

primitive _Archive

class val _Helpers
  let archive_EOF: I32 = -1
  let archive_OK: I32 = 0
  fun check(err: I32, p: Pointer[_Archive], out: (OutStream | None)): Bool =>
    if err < archive_OK then
      match out
      | let o: OutStream => 
        let cs = String.from_cstring(@archive_error_string(p))
        o.write("Error out: " + cs.clone() + "\n")
      | None => None
      end
      false
    else
      true
    end


actor Main
  new create(env: Env) => 
    env.out.print("Starting to decode")
    let filename = "data/corral.tar.gz"
    let helper: _Helpers val = _Helpers
    let arch = @archive_read_new()
    let ext = @archive_write_disk_new()
    var entry = Pointer[_Archive]
    let tmp_dir = "data"
    //  try
    //    FilePath.mkdtemp(env.root as AmbientAuth, "temp-dir")?
    //  else
    //    env.out.print("Cannot make temp dir, error")
    //    return 
    //  end
    var err: I32 = 0
    try
    err = @archive_read_support_compression_gzip(arch)
    Assert(helper.check(err, arch, env.out), "ERR: Support gzip compression")?
    err = @archive_read_support_compression_bzip2(arch)
    Assert(helper.check(err, arch, env.out), "ERR: Support bzip compression")?
    err = @archive_read_support_compression_lzip(arch)
    Assert(helper.check(err, arch, env.out), "ERR: Support lzip compression")?
    err = @archive_read_support_format_all(arch)
    Assert(helper.check(err, arch, env.out), "ERR: Support zip format")?
    err = @archive_read_open_filename(arch, filename.cstring(), 10240)
    Assert(helper.check(err, arch, env.out), "ERR: open File")?
    env.out.print("Loaded files")
    while true do 
      err = @archive_read_next_header(arch, addressof entry)
      if err != helper.archive_OK then
        env.out.print("EOF")
        break
      end
      let cs = String.from_cstring(@archive_entry_pathname(entry))
      env.out.print(cs.clone())
    end
    @archive_read_free(arch)
    end