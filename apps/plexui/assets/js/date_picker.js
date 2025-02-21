// scrollIntoView({ behavior: 'smooth' })
export default DataPicker = {
    mounted() {
        class Calendar {
            constructor(inputSelector) {
                this.input = inputSelector;
                this.name = inputSelector.dataset.name;
                this.form = this.input.parentElement;
                this.popupContainer = null;
                this.monthContainer = null;
                this.tableContainer = null;
                this.table = document.createElement("table");
                this.months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
                this.selectedMonth = new Date().getMonth();
                this.selectedYear = new Date().getFullYear();

                this.buildCalendar();
                this.setMainEventListener();
            }

            buildCalendar() {
                this.popupContainer = document.createElement("div");
                this.popupContainer.classList.add("calendar-popup");
                this.form.appendChild(this.popupContainer);


                this.monthContainer = document.createElement("div");
                this.monthContainer.classList.add("month-and-year");
                this.monthContainer.innerHTML = `<h4>${this.getMonth()} ${this.getYear()}</h4>`;
                this.popupContainer.appendChild(this.monthContainer);

                this.createButtons();

                this.populateTable(this.selectedMonth, this.selectedYear);
            }

            createButtons() {
                const prev = document.createElement("button");
                prev.classList.add('button', 'prev');
                prev.innerHTML = "<i class='fas fa-chevron-left'></i>";
                const next = document.createElement("button");
                next.classList.add('button', 'next');
                next.innerHTML = "<i class='fas fa-chevron-right'></i>";

                prev.addEventListener("click", e => {
                    e.preventDefault();
                    this.updateMonth(this.selectedMonth - 1);
                });

                next.addEventListener("click", e => {
                    e.preventDefault();
                    this.updateMonth(this.selectedMonth + 1);
                });

                this.popupContainer.appendChild(prev);
                this.popupContainer.appendChild(next);
            }

            populateTable(month, year) {
                this.table.innerHTML = "";

                const namesRow = document.createElement("tr");
                ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].forEach(name => {
                    const th = document.createElement("th");
                    th.innerHTML = name;
                    namesRow.appendChild(th);
                });
                this.table.appendChild(namesRow);

                const tempDate = new Date(year, month, 1);
                let firstMonthDay = tempDate.getDay();
                firstMonthDay = firstMonthDay === 0 ? 7 : tempDate.getDay();

                const daysInMonth = this.getDaysInMonth(month, year);
                const j = daysInMonth + firstMonthDay - 1;

                let tr = document.createElement("tr");

                if (firstMonthDay - 1 !== 0) {
                    tr = document.createElement("tr");
                    this.table.appendChild(tr);
                }

                for (let i = 0; i < firstMonthDay - 1; i++) {
                    const td = document.createElement("td");
                    td.innerHTML = "";
                    tr.appendChild(td);
                }

                for (let i = firstMonthDay - 1; i < j; i++) {
                    if (i % 7 === 0) {
                        tr = document.createElement("tr");
                        this.table.appendChild(tr);
                    }

                    const td = document.createElement("td");
                    td.innerText = i - firstMonthDay + 2;
                    td.dayNr = i - firstMonthDay + 2;
                    td.classList.add("day");

                    td.addEventListener("click", e => {
                        const selectedDay = e.target.innerHTML;
                        this.fillInput(selectedDay);
                        this.hideCalendar();
                    });

                    tr.appendChild(td);
                }

                this.popupContainer.appendChild(this.table);
            }

            fillInput(day) {
                day = day < 10 ? "0" + day : day;
                let month = null;
                month = this.selectedMonth < 9 ? "0" + (this.selectedMonth + 1) : this.selectedMonth + 1;
                // this.input.value = `${day}.${month}.${this.selectedYear}`;
                this.input.value = `${this.selectedYear}-${month}-${day}`;
                // console.log(this.name, this.input.value)

                const d1 = document.querySelector('.date-input-1')?.value
                const d2 = document.querySelector('.date-input-2')?.value

                if (d1 && d2) {
                    console.log(d1, d2)
                    // Create a link element
                    const link = document.createElement('a');
                    link.href = `download/${d1}/${d2}`;
                    link.className = 'text-purple-600 hover:text-blue-900 font-bold text-center block mt-4 pt-8 text-xl';
                    link.text = `Download Report from ${d1} to ${d2}`;

                    // Get the parent container to append the link
                    const container = document.querySelector('.container');

                    // Check if the link already exists to avoid duplicates
                    const existingLink = container.querySelector('a');
                    if (existingLink) {
                        existingLink.remove();
                    }

                    // Append the link
                    container.appendChild(link);
                }

            }

            updateMonth(month) {
                this.selectedMonth = month;
                if (this.selectedMonth < 0) {
                    this.selectedYear--;
                    this.selectedMonth = 11;
                } else if (this.selectedMonth > 11) {
                    this.selectedYear++;
                    this.selectedMonth = 0;
                }
                this.monthContainer.innerHTML = `<h4>${this.months[this.selectedMonth]} ${this.selectedYear}</h4>`;

                this.populateTable(this.selectedMonth, this.selectedYear)
            }

            getMonth() {
                return this.months[this.selectedMonth];
            }

            getYear() {
                return this.selectedYear;
            }

            getDaysInMonth(month, year) {
                return new Date(year, month + 1, 0).getDate();
            }

            hideCalendar() {
                this.form.classList.remove("open");
            }

            setMainEventListener() {
                this.input.addEventListener("click", e => {
                    this.form.classList.toggle("open");

                    if (!this.form.classList.contains("open")) {
                        this.hideCalendar();
                    }
                });
            }
        }

        new Calendar(this.el);
    }
}