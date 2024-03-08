import { LightningElement, api } from 'lwc';

export default class DsDatePicker extends LightningElement {
    @api error;
    @api label;

    open = false;

    firstOfViewedMonth;
    displayMonthString;
    userInput = '';

    selectedDate;
    lastFocusedDate;

    connectedCallback() {
        const today = new Date();
        this.firstOfViewedMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    }

    @api
    getValue() {
        return this.selectedDate;
    }

    @api
    focus() {
        this.template.querySelector('.navds-date__field-input')?.focus();
    }

    flipOpen() {
        this.open = !this.open;
        const modal = this.template.querySelector('.navds-modal');
        if (this.open) {
            modal.setAttribute('open', '');
            this.generateCalender();
        } else {
            modal.removeAttribute('open');
        }
    }

    get hasError() {
        return this.error != null;
    }

    generateCalender() {
        this.updateDisplayText();

        const monday = new Date(this.firstOfViewedMonth);
        const firstDay = monday.getDay(),
            diff = monday.getDate() - firstDay + (firstDay === 0 ? -6 : 1);
        monday.setDate(diff);

        const tBody = this.template.querySelector('.rdp-tbody');
        // eslint-disable-next-line @lwc/lwc/no-inner-html
        tBody.innerHTML = '';

        for (let week = 0; week < 6; week++) {
            const tRow = document.createElement('tr');
            tRow.classList.add('rdp-row');

            for (let day = 0; day < 7; day++) {
                const dateLoop = new Date(monday);
                dateLoop.setDate(monday.getDate() + day + week * 7);
                const isDayInMonth = dateLoop.getMonth() === this.firstOfViewedMonth.getMonth();
                const isToday = dateLoop.setHours(0, 0, 0, 0) === new Date().setHours(0, 0, 0, 0);
                const isSelected = dateLoop.setHours(0, 0, 0, 0) === this.selectedDate?.setHours(0, 0, 0, 0);
                const isLastViewedDate = dateLoop.getDate().toString() === this.lastFocusedDate;

                const tData = document.createElement('td');
                tData.classList.add('rpd-cell');

                const btn = document.createElement('button');
                btn.className =
                    'rdp-button_reset rdp-button rdp-day' +
                    (isDayInMonth ? '' : ' rdp-day_outside') +
                    (isToday ? ' rdp-day_today' : '') +
                    (isSelected ? ' rdp-day_selected' : '');
                btn.name = 'day';
                btn.role = 'gridcell';
                btn.tabIndex = isLastViewedDate | (this.lastFocusedDate == null && isSelected | isToday) ? 0 : -1;
                btn.ariaLabel = dateLoop.toLocaleDateString('no-nb', {
                    weekday: 'long',
                    day: 'numeric'
                });
                if (!isDayInMonth) btn.ariaHidden = true;
                btn.type = 'button';
                btn.onclick = (e) => this.calenderCellSelected(e);
                btn.innerText = dateLoop.getDate();
                tData.appendChild(btn);
                tRow.appendChild(tData);
            }
            tBody.appendChild(tRow);
        }
    }

    calenderCellSelected(event) {
        const selectedDate = new Date(this.firstOfViewedMonth);
        selectedDate.setDate(event.target.innerText);
        this.selectedDate = selectedDate;
        this.flipOpen();
    }

    prevMonth() {
        this.lastFocusedDate = '1';
        this.updateMonth(-1);
    }

    nextMonth() {
        this.lastFocusedDate = '1';
        this.updateMonth(1);
    }

    updateMonth(amount) {
        this.firstOfViewedMonth.setMonth(this.firstOfViewedMonth.getMonth() + amount);
        this.generateCalender();
    }

    updateDisplayText() {
        this.displayMonthString = this.firstOfViewedMonth.toLocaleDateString('no-nb', {
            month: 'long',
            year: 'numeric'
        });
    }

    get formattedDate() {
        if (!this.selectedDate) return this.userInput;
        return (
            String(this.selectedDate.getDate()).padStart(2, '0') +
            '.' +
            String(this.selectedDate.getMonth() + 1).padStart(2, '0') +
            '.' +
            this.selectedDate.getFullYear()
        );
    }

    testKnight() {
        const a = this.template.querySelector('.navds-date__field-input');
        this.setSelectedDateFromValue(a.value);
    }

    setSelectedDateFromValue(dateString) {
        // Breaks up the user input into 5 sections, 1 and 2 are used for days, 3 and 4 for months and 5 for year
        // 1,3 and 5 are default, 2 and 4 are for single digit days and/or months, which we pad with 0 later.
        let pattern =
            /^(?:([\d]{2})[/.,-/]*|([1-9])[/.,-/]+)(?:(0[1-9]|1[0-2])[/.,-/]*|([1-9])[/.,-/]+)([\d]{4}|[\d]{2})$/;
        const inputMatches = pattern.exec(dateString);
        if (!inputMatches) {
            console.log('No match');
            console.log(inputMatches);
            this.userInput = dateString;
            this.selectedDate = null;
            return;
        }
        console.log(inputMatches);
        const day = inputMatches[1] != null ? inputMatches[1] : inputMatches[2].padStart(2, '0'),
            month = inputMatches[3] != null ? inputMatches[3] : inputMatches[4].padStart(2, '0'),
            year = inputMatches[5].length < 4 ? this.generateYearFromTwoDigits(inputMatches[5]) : inputMatches[5];
        // const strength = dateString.split('.');
        const wantedDate = new Date(year, month - 1, day);
        if (String(wantedDate.getDate()).padStart(2, '0') !== day) {
            console.log('Got shafted');
            console.log(wantedDate);
            this.userInput = dateString;
            this.selectedDate = null;
            return;
        }
        this.userInput = '';
        this.selectedDate = new Date(wantedDate);
        this.lastFocusedDate = String(this.selectedDate.getDate());
        this.firstOfViewedMonth = new Date(wantedDate.setDate(1));
        if (this.open) this.generateCalender();
    }

    generateYearFromTwoDigits(year) {
        const currentYear = new Date().getFullYear();
        if (year <= String(currentYear + 5).slice(2, 4)) return String(currentYear).slice(0, 2) + year;
        return String(currentYear - 100).slice(0, 2) + year;
    }

    moveCalender(event) {
        if (
            (event.key === 'ArrowLeft') |
            (event.key === 'ArrowRight') |
            (event.key === 'ArrowUp') |
            (event.key === 'ArrowDown')
        ) {
            event.preventDefault();
            const date = parseInt(document.activeElement.innerText, 10);
            document.activeElement.tabIndex = -1;
            this.navigateDateKey(date, event.key);
        }
    }

    navigateDateKey(date, eventKey) {
        const dayArray = this.template.querySelectorAll('.rdp-day:not(.rdp-day_outside)');
        let a;
        switch (eventKey) {
            case 'ArrowLeft':
                if (date <= 1) {
                    this.lastFocusedDate = null;
                    this.updateMonth(-1);
                    this.navigateDateKey(-1, 'PrevMonth');
                } else {
                    a = dayArray[date - 2];
                }
                break;
            case 'ArrowRight':
                if (date >= dayArray.length) {
                    this.lastFocusedDate = null;
                    this.updateMonth(1);
                    this.navigateDateKey(1, 'NextMonth');
                } else {
                    a = dayArray[date];
                }
                break;
            case 'ArrowUp':
                if (date - 6 <= 1) {
                    this.lastFocusedDate = null;
                    this.updateMonth(-1);
                    this.navigateDateKey(date - 8, 'PrevMonth');
                } else {
                    a = dayArray[date - 8];
                }
                break;
            case 'ArrowDown':
                if (date + 6 >= dayArray.length) {
                    this.lastFocusedDate = null;
                    this.updateMonth(1);
                    this.navigateDateKey(date - dayArray.length + 7, 'NextMonth');
                } else {
                    a = dayArray[date + 6];
                }
                break;
            case 'NextMonth':
                a = dayArray[date - 1];
                break;
            case 'PrevMonth':
                a = dayArray[dayArray.length + date];
                break;
            default:
                break;
        }
        if (a) {
            this.lastFocusedDate = a.innerText;
            a.tabIndex = 0;
            a.focus();
        }
    }
}
