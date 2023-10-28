// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// Bring in Phoenix channels client library:
import { Socket } from "phoenix"

// And connect to the path in "lib/mweso_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.
let socket = new Socket("/socket", { params: { token: window.userToken } })

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/mweso_web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/mweso_web/templates/layout/app.html.heex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/mweso_web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1_209_600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect()

// Now that you are connected, you can join channels with a topic.
// Let's assume you have a channel with a topic named `room` and the
// subtopic is its id - in this case 42:
let channel = socket.channel("room:game", {})

let innerGrid = document.querySelector("#inner_grid")



channel.join()
  .receive("ok", resp => {
    console.log("Joined successfully", resp)

    channel.push("start");
  })
  .receive("error", resp => { console.log("Unable to join", resp) })

let player1grounds = []
let player2grounds = []

let groundClick = (index) => {
  if(player1grounds[index]["seeds"] <= 1) return;
  channel.push("ground_click", {index})
}
channel.on("view_update", payload => {
  let { player1, player2, seeds1 } = payload
  player1grounds = player1 
  player2grounds = player2 

  for (let i = 7; i >= 0; i--) {
    let button = document.createElement("button")
    button.classList.add(player1[i].color, "rounded-full", "hover:bg-cyan-600", "w-14", "h-14", "text-2xl")
    button.setAttribute("id", `${player1[i].ground}player1`)
    button.onclick = (event) => groundClick(i)

    // button.ondblclick
    button.textContent = player1[i].seeds
    innerGrid.prepend(button)
  }

  for (let i = 8; i < 16; i++) {
    let button = document.createElement("button")
    button.classList.add(player1[i].color, "rounded-full", "hover:bg-cyan-600", "w-14", "h-14", "text-2xl")
    button.setAttribute("id", `${player1[i].ground}player1`)
    button.onclick = (event) => groundClick(i)
    // button.ondblclick
    button.textContent = player1[i].seeds
    innerGrid.prepend(button)
  }

  for (let i = 15; i >= 8; i--) {
    let button = document.createElement("button")
    button.classList.add(player2[i].color, "rounded-full", "hover:bg-cyan-600", "w-14", "h-14", "text-2xl")
    button.setAttribute("id", `${player2[i].ground}player2`)
    button.textContent = player2[i].seeds
    innerGrid.prepend(button)
  }
  for (let i = 0; i <= 7; i++) {
    let button = document.createElement("button")
    button.classList.add(player2[i].color, "rounded-full", "hover:bg-cyan-600", "w-14", "h-14", "text-2xl")
    button.setAttribute("id", `${player2[i].ground}player2`)
    button.textContent = player2[i].seeds
    innerGrid.prepend(button)
  }

})

channel.on("update_game", payload => {
  let { player1, player2, seeds1 } = payload
  player1grounds = player1 
  player2grounds = player2 

  document.getElementById("seeds1").textContent = seeds1

  for (let i = 0; i < 16; i++) {
    let button1 = document.getElementById(`${player1[i].ground}player1`)
    let button2 = document.getElementById(`${player2[i].ground}player2`)

    button1.textContent = player1[i].seeds
    button2.textContent = player2[i].seeds

    button1.className
  }
})

export default socket
