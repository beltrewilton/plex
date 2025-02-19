import Chart from "chart.js/auto";

export default ScoreGauge = {
    mounted() {
        if (!this.el) return; // Ensure element exists

        let ctx = this.el.getContext("2d");
        const score = this.el.dataset.score
        const maxValue = this.el.dataset.maxvalue
        const remainingValue = maxValue - score
        const _title = this.el.dataset.label
        const backgroundColor = this.el.dataset.bgcolor
        const labelValue = score

        // Custom plugin to add text in the center
        const centerTextPlugin = {
            id: "centerText",
            beforeDraw(chart) {
                const { width } = chart;
                const { top, height } = chart.chartArea;
                const ctx = chart.ctx;

                ctx.save();
                ctx.font = "29px sans-serif";
                ctx.fillStyle = "#000";
                ctx.textAlign = "center";
                ctx.textBaseline = "middle";
                ctx.fillText(labelValue, width / 2, top + height / 2);
                ctx.restore();
            },
        };

        const config = {
            type: "doughnut",
            data: {
                datasets: [
                    {
                        data: [score, remainingValue],
                        backgroundColor: [backgroundColor, "#dddddd"],
                    },
                ],
            },
            options: {
                aspectRatio: 1.9,
                responsive: false, // When true, it causes an error in Phoenix.
                maintainAspectRatio: false,
                cutout: "80%",
                plugins: {
                    title: {
                        display: true,
                        text: _title,
                        padding: 0,
                        font: "ui-monospace"
                    },
                    tooltip: {
                        enabled: false,
                    },
                },
                layout: {
                    padding: 20,
                },
            },
            plugins: [centerTextPlugin], // Register the custom plugin
        };

        new Chart(ctx, config);
    },
};
