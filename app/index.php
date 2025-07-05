<div>

    <script>
    document.addEventListener("DOMContentLoaded", function() {
        var iframe = document.getElementById('grafana-iframe');

        const url = new URL(window.location.href);
        iframe.setAttribute('src', "https://" + url.hostname + ':47474');
    });
    </script>

    <iframe id="grafana-iframe"
            style="width: 100%; height: 100vh; border: none;"
            title="Grafana Dashboard">
    </iframe>
</div>