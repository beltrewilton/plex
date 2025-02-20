import Chart from 'chart.js/auto'

export default HalfGauge = {
    mounted() {
        let ctx = this.el

        const lead_max_temperature = 1.0
        const lead_temperature = parseFloat(this.el.dataset.lead_temperature)
        const lead_heat_check_text = this.el.dataset.lead_heat_check
        const _title = this.el.dataset.label

        console.log("lead_heat_check_text", lead_heat_check_text)

        const strokeColor = (lead_temperature) => {
            if (lead_temperature > 0.6) {
                return "#ff0000"; // Red
            } else if (lead_temperature >= 0.5) {
                return "#ffa500"; // Orange
            } else {
                return "#ffff00"; // Yellow
            }
        }

        const config = {
            type: "doughnut",
            data: {
                datasets: [
                    {
                        data: [lead_temperature, 1 - lead_temperature],
                        backgroundColor: [strokeColor(lead_temperature), "#dddddd"],
                        label: _title,
                    },
                ],
            },
            options: {
                circumference: 180,
                rotation: 270,
                responsive: false,
                maintainAspectRatio: false,
                cutout: "70%",
                layout: {
                    padding: 5,
                },
                plugins: {
                    title: {
                        display: true,
                        text: _title,
                        padding: 4,
                        font: "ui-monospace"
                    },
                    tooltip: {
                        displayColors: false,
                        callbacks: {
                            label: function (tooltipItem) {
                                if (tooltipItem.dataIndex === 0) {
                                    return "Value: " + lead_temperature;
                                }
                                return "Max: " + lead_max_temperature;
                            },
                        },
                    },
                },
                aspectRatio: 3.1,
            },
            plugins: [
                {
                    id: "centerText",
                    afterDraw: function (chart) {
                        const { ctx, chartArea } = chart;
                        if (!chartArea) return;

                        ctx.save();
                        ctx.font = "17px sans-serif";
                        // ctx.fillStyle = "#ff0000";
                        ctx.textAlign = "center";
                        ctx.textBaseline = "middle";

                        // Adjust positioning
                        const centerX = chart.width / 2;
                        const centerY = chart.height / 1.2;

                        ctx.fillText(lead_heat_check_text?.toUpperCase(), centerX, centerY);
                        ctx.restore();
                    },
                },
            ],
        };

        new Chart(ctx, config);
    }
}
