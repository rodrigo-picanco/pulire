<html>
  <head>
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
  </head>
  <body class="mx-auto w-5xl flex flex-col gap-8">
    <div>
       <h1 class="font-sans font-black text-9xl uppercase">pulire</h1>
        <nav>
          {{ if .Filter }}
            <a href="/" class="underline">Daily tasks</a> 
          {{ else }}
            <a href="?period=all" class="underline">All tasks</a>
          {{ end }}
        </nav>
      </div>


     <main class="flex">
      <div class="grow flex gap-4 flex-col">
        {{ $filter := .Filter }}
        {{ range .Rooms }}
          {{ if gt (len .Tasks) 0 }}
            <div>
              <h3 class="text-xl font-bold text-stone-500">{{ .Name }}</h3>
              {{ range .Tasks }}
                <div class="flex gap-2 items-center">
                  {{ if $filter }}
                    <form action="/task/{{ .ID }}/delete">
                      <button class="cursor-pointer bg-stone-700 hover:bg-stone-800 text-white rounded-full border-1 px-1 py-1 w-8 h-8">✗</button>
                    </form>
                  {{ else }}
                    <form action="/task/{{ .ID }}">
                      <button class="cursor-pointer bg-stone-700 hover:bg-stone-800 text-white rounded-full border-1 px-1 py-1 w-8 h-8">✓</button>
                    </form>
                  {{ end }}
                  <div>
                    <h4 class="text-xl">{{ .Name }}</h4>
                    <p class="text-sm text-stone-400">Every
                      {{ if gt .Period 1 }}
                        {{ .Period }} weeks 
                      {{else}} 
                        week 
                      {{end}}
                    </p>
                  </div>
                </div>
              {{ end }}
            </div>
          {{ end }}
        {{ else }}
          {{ if $filter }}
            <h2>No tasks created</h2>
          {{ else }}
            <h2>All neat!</h2>
          {{ end }}
        {{ end }}
      </div>


      {{ if .Filter }}
        <form action="/task" class="flex flex-col gap-2 border-l border-stone-600 p-2" method="POST">
          <input  class="border-1 rounded-xl px-2 py-1" required type="text" name="name" placeholder="Vacuum" required />
          <input class="border-1 rounded-xl px-2 py-1" name="room" placeholder="Living room" list="rooms" required>
          <datalist id="rooms">
            {{ range .Rooms }}
              <option value="{{ .Name}}">{{ .Name }}</option>
            {{ end }}
          </datalist>
          <input class="border-1 rounded-xl px-2 py-1" required type="number" name="period" placeholder="1" min="1" value="1" required/>
          <button class="cursor-pointer bg-stone-700 hover:bg-stone-800 px-2 py-1 rounded-xl text-white" type="submit">Add task</button>
        </form>
      {{ end }}
    </main>

  </body>
</html>
