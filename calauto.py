import facebook, re, sys, os
from datetime import datetime, date

dateSet = False
argv = sys.argv
#print(argv)
for arg in argv :
    index = argv.index(arg)
    print(index)
    print(len(argv))
    if '-' in arg :
        #print("!")
        if 'd' in arg :
            if len(argv) <= (index+1) :
                print("Error! Usage: [-d YYMMDD]")
                quit()
            for n in argv[index+1] :
                if n not in ['1','2','3','4','5','6','7','8','9','0'] :
                    print("Error! Usage: [-d YYMMDD]")
                    quit()
            dateSet = True
            if len(argv[index+1]) < 6 :
                print("Syntax error! Usage: [-d YYMMDD]")
                quit()
            else :
                someDate = argv[index+1][4:6]
                if int(someDate) > 31 :
                    print("Invalid date.")
                    quit()
                someMonth = argv[index+1][2:4]
                if int(someMonth) > 12 :
                    print("Invalid month.")
                    quit()
                someYear = argv[index+1][0:2]
                if int(someYear) < 10 or int(someYear) > 22 :
                    print("Really dude?")
                    quit()
                dateStr=date(int(someYear)+2000,int(someMonth),int(someDate))
    elif dateSet == False :
        dateStr = date.today()
            #    print(someDate, someMonth)


#os.system("rclone sync CVO:Ulfen/kalendarium ~/CVO/kalendarium/")
#os.system("docx2txt ~/CVO/kalendarium/Kalendarium_17-18.docx kalendarium.txt")

weekdays = ['Mån','Tis','Ons','Tor','Fre','Lör','Sön']
months = 'JanuariFebruariMarsAprilMajJuniJuliAugustiSeptemberOktoberNovemberDecember'

eventDates = []
eventDays = []
eventTitle = []
eventWeeks = []
with open("kalendarium.txt", 'r') as inputCal :
    for line in inputCal.readlines() :
        if "/" in line :
            for part in line.split("\t") :
                otherPart = re.sub('\n','',part)
                if "/" in part :
                    eventDates.append(part)
                elif otherPart in weekdays :
                    eventDays.append(otherPart)
                else :
                    newPart = re.sub('\n','',part)
                    eventTitle.append(newPart)

events = {}
for f in eventDates :
    index = eventDates.index(f)
    if f.find("/") == 1 :
        eventDates[index] = "0" + eventDates[index]
    if "/" in f[-2] :
        last = f[-1]
        eventDates[index] = eventDates[index][0:3] + "0" + last
    findNum = re.compile('[0-9]{1,2}')
    tempDate = re.match('[0-9]{1,2}/', eventDates[index])
    tempMonth = re.search('/[0-9]{1,2}', eventDates[index])
    startDate = tempDate.start()
    endDate = tempMonth.end()
    startMonth = tempMonth.start()
    endMonth = tempMonth.end()
    fDate = eventDates[index][tempDate.start():tempDate.end()-1]
    fMonth = eventDates[index][tempMonth.start()+1:tempMonth.end()]
    
    if fMonth in ['07','08','09','10','11','12'] :
        fYear = 2017
    else :
        fYear = 2018
    fTotal = date(int(fYear),int(fMonth),int(fDate))
    fWeek = fTotal.strftime("%W")
    eventWeeks.append(fWeek)
    events[eventDates[index]] = [eventDays[index], eventTitle[index], fWeek]

actToday = dateStr.strftime('%D')
actDate = actToday[0:2]
actMonth = actToday[3:5]
actTotal = actDate + "/" + actMonth
realWeek = dateStr.strftime("%W")
actDay = dateStr.strftime("%w")

thisWeek = {}
for date in events.keys() :
    if realWeek == events[date][2] :
        thisWeek[date] = events[date]

#print(thisWeek, len(thisWeek))
actWeek = [0,0,0,0,0,0,0]
for day in weekdays :
    for f in thisWeek.keys() :
        if day == thisWeek[f][0] :
            actWeek[weekdays.index(day)] = [thisWeek[f][0],f, thisWeek[f][1]]

#print(actWeek, len(actWeek))
finWeek = []
for day in actWeek :
    if day != 0 :
        finWeek.append(day)
#print(finWeek, len(finWeek))

with open("output.txt", 'w+') as message :
    message.write("Dåne!\nHär kommer en uppdatering av vad som händer vecka "+realWeek+":\n\n")
    for line in range(len(finWeek)) :
        message.write(finWeek[line][0]+"\t"+finWeek[line][1]+"\t"+finWeek[line][2]+"\n")
    message.write("\n/CVO\n")
