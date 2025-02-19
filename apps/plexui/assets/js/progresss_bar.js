import Chart from "chart.js/auto";

export default ProgressBar = {
    mounted() {
        if (!this.el) return; // Ensure the element exists

        let ctx = this.el

        const progressValue = ctx.dataset.progressvalue
        const bgcolor = ctx.dataset.bgcolor
        const maxValue = ctx.dataset.maxvalue || 9 ;

        // Custom plugin to show progress text inside the bar
        const progressTextPlugin = {
            id: "progressText",
            afterDatasetsDraw(chart) {
                const { ctx } = chart;
                const dataset = chart.data.datasets[0];

                chart.getDatasetMeta(0).data.forEach((bar, index) => {
                    const value = dataset.data[index];
                    ctx.fillStyle = "white";
                    ctx.font = "12px sans-serif";
                    ctx.textAlign = "center";
                    ctx.textBaseline = "middle";
                    ctx.fillText(`${value}`, bar.x - 20, bar.y);
                });
            },
        };

        const config = {
            type: "bar",
            data: {
                labels: [""], // Single bar
                datasets: [
                    {
                        data: [progressValue],
                        backgroundColor: bgcolor,
                        borderRadius: 3,
                        barPercentage: 1, // Full width
                        categoryPercentage: 1, // Full height
                    },
                ],
            },
            options: {
                indexAxis: "y", // Horizontal bar
                responsive: false,
                maintainAspectRatio: false,
                scales: {
                    x: {
                        min: 0,
                        max: maxValue,
                        display: false, // Hide axis
                    },
                    y: {
                        display: false, // Hide axis
                    },
                },
                plugins: {
                    legend: { display: false },
                    tooltip: { enabled: false },
                },
            },
            plugins: [progressTextPlugin],
        };

        new Chart(ctx, config);
    },
};
