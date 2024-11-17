<html>
  <head>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wdth,wght@75,300..800&display=swap" rel="stylesheet">
    <style>
      :root {
        --background: #fefffe;
        --radius: 4px;
        --text: #333;
        color: var(--text);
        font-family: sans-serif;
        font-family: "Open Sans", sans-serif;
        font-style: normal;
      }
      input, button {
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
      input {
        border-radius: var(--radius);
        border: 1px solid var(--text);
        padding: 0.5rem;
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
        height: 40px;
        width: 40px;
      }
      #add-task {
        display: grid;
        gap: 0.5rem;
      }
      #tasks {
        display: grid;
        gap: 2rem;
      }
      .task {
        border-bottom: 3px solid var(--text);
        display: grid;
        grid-template-columns: 1fr auto;
        padding: 0.5rem 0;
        h3 {
          text-transform: uppercase;
          font-size: 1.25rem;
        }
        form {
          align-self: center;
        }
      }
    </style>
  </head>
  <body>
   <main>
     <h1>pulire</h1>
      <nav>
        {{ if .period }}
          <a href="/">Daily tasks</a> 
        {{ else }}
          <a href="?period=all">All tasks</a>
        {{ end }}
      </nav>
      <div id="tasks">
        {{ range .tasks }}
          <article class="task">
            <div>
              <h3>{{ .Name }}</h3>
              </p>Every {{ .Period }} week(s)</p>
              {{ if .LastCompleted }}
                <p>Last completed {{ dateformat .LastCompleted }}</p>
              {{ else }}
                <p>Never done</p>
              {{ end }}
            </div>
            <form action="/task/{{ .ID }}" method="POST">
              <button class="pill" type="submit">&#x2714;</button>
            </form>
          </article>
        {{ else }}
          <h3>No tasks today!</h3>
        {{ end }}
      </div>
      <div>
        <form action="/task" method="POST" id="add-task">
          <input required type="text" name="name" placeholder="Name" fo />
          <input required type="number" name="period" placeholder="Weeks" />
          <button type="submit">Add task</button>
        </form>
      </div>
    </main>
  </body>
</html>
