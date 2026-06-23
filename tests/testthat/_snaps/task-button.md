# block_task_button() renders a stable tag

    Code
      cat(render_html(block_task_button("run", "Run analysis", label_busy = "Working",
        variant = "secondary")))
    Output
      <div id="sb-runtime-task-button-run" class="sb-runtime-mount" data-shinyblocks-root="" data-shinyblocks-runtime="true" data-sb-component="task-button" data-sb-input-id="run">
        <script type="application/json" data-shinyblocks-payload="">{"schemaVersion":1,"component":"task-button","id":"run","props":{"labelHtml":"Run analysis","labelBusy":"Working","variant":"secondary","size":"default","iconName":null,"iconHtml":null,"iconBusyName":null,"iconBusyHtml":null,"iconPosition":"inline-start","spriteHref":"shinyblocks/icons/sprite.svg","attrs":[],"style":null,"disabled":false,"autoReset":true},"slots":[],"children":[],"state":{"value":0,"state":"ready"},"binding":{"input":true,"type":"shinyblocks.task_button"},"className":null,"style":null}</script>
        <div data-shinyblocks-react=""></div>
        <div data-shinyblocks-children=""></div>
      </div>

