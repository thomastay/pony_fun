use "net"
use "files"

actor Main
  new create(env: Env) =>
  let fileName = "hello.html"
    try
      let path = FilePath(env.root as AmbientAuth, fileName)?
      let file =  OpenFile(path) as File
      let htmlData = recover val file.read_string(2056) end
      try TCPListener(env.root as AmbientAuth,
                Listener(env.out, htmlData),
                "127.0.0.1", "7878")
      else env.err.print("unable to use the network")
      end
    else
      env.err.print("Unable to read from file: "+ fileName)
    end

class Listener is TCPListenNotify
  let _out: OutStream
  var _host: String = ""
  var _port: String = ""
  var _htmlData: String

  new iso create(out: OutStream, htmlData: String) =>
    _out = out
    _htmlData = htmlData

  fun ref listening(listen: TCPListener ref) =>
    try
      (_host, _port) = listen.local_address().name()?
      _out.print("listening on " + _host + ":" + _port)
    else
      _out.print("couldn't get local address")
      listen.close()
    end

  fun ref not_listening(listen: TCPListener ref) =>
    _out.print("couldn't listen")
    listen.close()

  fun ref connected(listen: TCPListener ref): TCPConnectionNotify iso^ =>
    Server(_out, _htmlData)