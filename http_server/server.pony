use "net"
use "collections"

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
    let data = String.from_array(consume data')
    _out.print("Request!\n" + data)
    _out.print("sleeping now...")
    let s = spin()
    let header = "HTTP/1.1 200 OK\r\n\r\n"
    let header404 = "HTTP/1.1 404 Not Found\r\n\r\n"
    let get = "GET / HTTP/1.1\r\n"
    // handle request
    if data.at(get, 0) then 
      conn.write(header + _htmlData) 
    else
      conn.write(header404)
    end
    conn.write(s)
    conn.dispose()
    _out.print("Connection handled.")
    false

  // simulate doing work
  fun spin(): String =>
    let s = recover iso String end
    s.append("<p>")
    for i in Range(1, 1000000) do 
      s.append(i.string())
    end
    s.append("</p>")
    s

  fun ref closed(conn: TCPConnection ref) =>
    _out.print("Client closed the request")

  fun ref connect_failed(conn: TCPConnection ref) =>
    _out.print("connect failed")


