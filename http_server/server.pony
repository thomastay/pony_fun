use "net"
use "time"

class HandleConnection is TimerNotify
  let _conn: TCPConnection
  let _data: String
  let _htmlData: String
  let _out: OutStream

  new iso create(c: TCPConnection tag, d: String, h: String, o: OutStream) =>
    _conn = c
    _data = d
    _htmlData = h
    _out = o

  fun apply(_: Timer, _: U64): Bool =>
    let header = "HTTP/1.1 200 OK\r\n\r\n"
    let header404 = "HTTP/1.1 404 Not Found\r\n\r\n"
    let get = "GET / HTTP/1.1\r\n"
    // handle request
    if _data.at(get, 0) then 
      _conn.write(header + _htmlData) 
    else
      _conn.write(header404)
    end
    _conn.dispose()
    _out.print("Connection handled.")
    false // don't loop the timer

class val Server is TCPConnectionNotify
  let _out: OutStream
  let _htmlData: String

  new iso create(out: OutStream, htmlData: String) =>
    _out = out
    _htmlData = htmlData

  fun accepted(conn: TCPConnection ref) =>
    _out.print("connection accepted")

  fun ref received(conn: TCPConnection ref, data': Array[U8] iso, _: USize)
  : Bool
  =>
    let data = recover val String.from_iso_array(consume data') end
    _out.print("Request!\n" + data)
    _out.print("sleeping now...")
    let timer = Timer(HandleConnection(conn, data, _htmlData, _out), 5_000_000_000, 0)
    Timers()(consume timer)
    false

  fun ref closed(conn: TCPConnection ref) =>
    _out.print("Client closed the request")

  fun ref connect_failed(conn: TCPConnection ref) =>
    _out.print("connect failed")


