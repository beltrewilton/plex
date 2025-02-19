import Chart from 'chart.js/auto'

export default HalfGauge = {
    mounted() {
        let ctx = this.el

        const lead_max_temperature = this.el.dataset.lead_max_temperature
        const lead_heat_check = this.el.dataset.lead_heat_check
        const _title = this.el.dataset.label

        console.log("lead_heat_check", lead_heat_check)

        const config = {
            type: "doughnut",
            data: {
                datasets: [
                    {
                        data: [lead_max_temperature, lead_heat_check - lead_max_temperature],
                        backgroundColor: ["#ffa500", "#dddddd"],
                        label: _title,
                    },
                ],
            },
            options: {
                circumference: 180,
                rotation: 270,
                responsive: false, // when true it cause error in phoenix.
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
                        font: "Consolas"
                    },
                    tooltip: {
                        displayColors: false,
                        callbacks: {
                            label: function (tooltipItem) {
                                if (tooltipItem.dataIndex === 0) {
                                    return _t("Value: ") + ledtempValue;
                                }
                                return _t("Max: ") + max;
                            },
                        },
                    },
                    // Adding the label in the center of the gauge
                    datalabels: {
                        display: true,
                        formatter: (value, context) => {
                            return context.dataIndex === 0 ? 'gaugeValue' : '';
                        },
                        color: "#000",
                        font: {
                            size: 20,
                            weight: 'bold',
                        },
                    },
                },
                aspectRatio: 3.1,
            },
        }

        new Chart(ctx, config)
    }
}