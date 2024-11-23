<html>
  <head>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wdth,wght@75,300..800&display=swap" rel="stylesheet">
    <style>
      @view-transition {
        navigation: auto;
      }
      :root {
        --background: #fefffe;
        --radius: 4px;
        --text: #333;
        color: var(--text);
        font-family: sans-serif;
        font-family: "Open Sans", sans-serif;
        font-style: normal;
      }
      input, button, select {
        font-family: "Open Sans", sans-serif;
      }
      * {
        margin-block-end: 0;
        margin-block-start: 0;
      }
      body {
        background: var(--background);
        margin: 0 auto;
        max-width: 960px;
        padding: 2rem;
      }
      h1 {
        border-bottom: 4px solid var(--text);
        font-family: sans-serif;
        font-size: 6rem;
        grid-column: 1 / span 2;
        letter-spacing: 0.5rem;
        padding-bottom: 1rem;
        text-align: right;
        text-transform: uppercase;
        transform: skew(-5deg);
      }
      main {
        display: grid;
        gap: 1rem;
        grid-template-columns: 2fr 1fr;
      }
      a {
        color: var(--text);
        font-size: 1.25rem;
      }
      nav {
        grid-column: 1 / span 2;
      }
      input, select {
        border-radius: var(--radius);
        border: 1px solid var(--text);
        padding: 0.5rem;
        font-size: 1rem;
      }
      button {
        background: var(--text);
        color: var(--background);
        border-radius: var(--radius);
        border: 1px solid var(--text);
        cursor: pointer;
        padding: 0.5rem;
      }
      .pill {
        border-radius: 100%;
        height: 30px;
        width: 30px;
        display: flex;
        justify-content: center;
        align-items: center;

        &.outline {
          background: var(--background);
          color: var(--text);
        }
      }
      .form {
        display: grid;
        gap: 0.5rem;
        padding: 0.5rem 0;
      }
      #tasks, #forms {
        display: flex;
        flex-direction: column;
        gap: 2rem;
      }

      #tasks {
        padding-right: 1rem;
        border-right: 3px solid var(--text);
      }

      .room:not(:first-child) {
        border-top: 3px solid var(--text);
        padding-top: 1rem;
      }
      .task {
        display: grid;
        grid-template-columns: 1fr auto;
        grid-column: auto;

        .actions {
          display: flex;
          gap: 0.5rem;
        }
      }
    </style>
  </head>
  <body>
   <main>
     <h1>pulire</h1>
      <nav>
        {{ if .Filter }}
          <a href="/">Daily tasks</a> 
        {{ else }}
          <a href="?period=all">All tasks</a>
        {{ end }}
      </nav>
      <div id="tasks">
        {{ $filter := .Filter }}
        {{ range .Rooms }}
          {{ if gt (len .Tasks) 0 }}
            <div class="room">
              <h3>{{ .Name }}</h3>
              {{ range .Tasks }}
                <div class="task">
                  <div>
                    <h4>{{ .Name }}</h4>
                    <p>Every
                      {{ if gt .Period 1 }}
                        {{ .Period }} weeks 
                      {{else}} 
                        week 
                      {{end}}
                    </p>
                  </div>
                  <div class="actions">
                    {{ if $filter }}
                      <form action="/task/{{ .ID }}/delete">
                        <button class="pill outline">✗</button>
                      </form>
                    {{ else }}
                      <form action="/task/{{ .ID }}">
                        <button class="pill outline">✓</button>
                      </form>
                    {{ end }}
                  </div>
                </div>
              {{ end }}
            </div>
          {{ end }}
        {{ end }}
      </div>
      {{ if .Filter }}
        <div id="forms">
          <form action="/task" method="POST" class="form">
            <input required type="text" name="name" placeholder="Task"  />
            <select name="room" placeholder="Room">
              {{ range .Rooms }}
                <option value="{{ .ID }}">{{ .Name }}</option>
              {{ end }}
            </select>
            <input required type="number" name="period" placeholder="Weeks" />
            <button type="submit">Add task</button>
          </form>
          <form action="/room" method="POST" class="form">
            <input required type="text" name="name" placeholder="Room" fo />
            <button type="submit">Add room</button>
          </form>
        </div>
      {{ end }}
    </main>
  </body>
</html>
