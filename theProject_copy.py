from tkinter import *
import time
from Pillow import ImageTk

 

def move_sheep(event):
    global sheepPosX, sheepPosY,i
    #print(sheepPosX)
    if event.keysym == 'Left' and sheepPosX > 145:
        if i != 1:
            i = 1
            canvas.itemconfig(theSheep, image=sheep[i])
        sheepPosX = sheepPosX - 4
        canvas.move(theSheep, -4, 0)
        
    elif event.keysym == 'Right' and sheepPosX < 400:
        if i != 0:
            i = 0
            canvas.itemconfig(theSheep, image=sheep[i])
        sheepPosX = sheepPosX + 4
        canvas.move(theSheep, 4, 0)
        

def jump_sheep(event):
    global sheepPosX, sheepPosY, i, stop, comingBack
    comingBack=True
    canvas.itemconfig(message, text='[I have to go down!]', font=('Courier',15))
    if i == 1:
        i = 3
        canvas.itemconfig(theSheep, image=sheep[i])
        while sheepPosX <= 640 and sheepPosY <= 400 :
            canvas.move(theSheep, -5, +5)
            sheepPosX = sheepPosX - 5
            sheepPosY = sheepPosY + 5
            tk.update()
            time.sleep(0.05)
    elif i == 0:
        i = 2
        canvas.itemconfig(theSheep, image=sheep[i])
        while sheepPosX <= 640 and sheepPosY <= 400 :
            canvas.move(theSheep, 5, 5)
            sheepPosX = sheepPosX + 5
            sheepPosY = sheepPosY + 5
            tk.update()
            time.sleep(0.05)
    comingBack=False


def takeback_sheep(event):
    global sheepPosX, sheepPosY,i,islandPosY, comingBack
    if sheepPosX <= 0 or sheepPosX >640 or sheepPosY >=400:
        comingBack=True
        canvas.itemconfig(message, text='[Coming back!]', font=('Courier',15))
        canvas.move(theSheep, (640-sheepPosX),(-sheepPosY))
        sheepPosX=640
        sheepPosY=0
        i=1
        canvas.itemconfig(theSheep, image=sheep[i])
        #print(sheepPosX, sheepPosY)
        for j in range(75):
            #print(sheepPosX, sheepPosY)
            sheepPosX-=5
            canvas.move(theSheep, -5,0)
            tk.update()
            time.sleep(0.05)
        while sheepPosY<islandPosY-25:
            sheepPosY+=5
            canvas.move(theSheep, 0,5)
            tk.update()
            time.sleep(0.05)
        #print(sheepPosX, sheepPosY)
        comingBack=False
        canvas.itemconfig(message, text='[I\'m the Queen in the blue sky.]', font=('Courier',15))

def eat_grass(event):
    global i
    if event.keysym == 'Down' and i == 0:
        i = 2
        canvas.itemconfig(theSheep, image=sheep[i])
    elif event.keysym == 'Down' and i == 1:
        i = 3
        canvas.itemconfig(theSheep, image=sheep[i])

def enter_game(event):
    global op
    if event.keysym == 'Return':
        op = False
        canvas.itemconfig(title, anchor=SE)
    


def animation():
    global islandPosY, sheepPosY, islandDirection, comingBack ,cloudPosX1, cloudPosX2
    
    if islandPosY == 140 or islandPosY == 120:
        islandDirection*=-1
        
    islandPosY+=(1*islandDirection)
    canvas.move(theIsland, 0, (1*islandDirection))
    if not comingBack:
        sheepPosY+=(1*islandDirection)
        canvas.move(theSheep,0,(1*islandDirection))

    cloudPosX1 = cloudPosX1 - 2
    canvas.move(theCloud1, -2, 0)
    if cloudPosX1 < -330:
        canvas.move(theCloud1, (600 - cloudPosX1), 0)
        cloudPosX1 = 600
    cloudPosX2 = cloudPosX2 + 2
    canvas.move(theCloud2, 2, 0)
    if cloudPosX2 >= 600:
        canvas.move(theCloud2, (-300 - cloudPosX2), 0)
        cloudPosX2 = -300
    #print(cloudPosX2)

    tk.update()
    canvas.after(100, animation)



tk = Tk()
tk.title("the Project")
tk.resizable(0, 0)
canvas = Canvas(tk, width=640, height=400, bd=0, highlightthickness=0)
canvas.pack()
background = PhotoImage(file='/home/momoko/Pictures/the Project/background_sky.gif')
cloud_back = PhotoImage(file='/home/momoko/Pictures/the Project/cloud_back.gif')
island = PhotoImage(file='/home/momoko/Pictures/the Project/island.gif')
cloud_move1 = ImageTk.PhotoImage(file='/home/momoko/Pictures/the Project/cloud_move.png')
cloud_move2 = ImageTk.PhotoImage(file='/home/momoko/Pictures/the Project/cloud_move2.png')

optitle = PhotoImage(file='/home/momoko/Pictures/the Project/title.gif')

sheep = []
  #right = 0
sheep.append(PhotoImage(file='/home/momoko/Pictures/the Project/sheep.gif'))
  #left = 1
sheep.append(PhotoImage(file='/home/momoko/Pictures/the Project/sheep_left.gif'))
  #down_right = 2
sheep.append(PhotoImage(file='/home/momoko/Pictures/the Project/sheep_down_right.gif'))
  #down_left = 3
sheep.append(PhotoImage(file='/home/momoko/Pictures/the Project/sheep_down_left.gif'))

sheepPosX = 285
sheepPosY = 100
i = 0  #muki
islandPosX = 150
islandPosY = 120
islandDirection=-1
comingBack = False
cloudPosX1 = 600
cloudPosY1 = 200
cloudPosX2 = -300 
cloudPosY2 = 250
op = True

canvas.create_image(0, 0, anchor=NW, image=background)
canvas.create_image(0, 0, anchor=NW, image=cloud_back)
theIsland = canvas.create_image(islandPosX, islandPosY, anchor=NW, image=island)
theCloud1 = canvas.create_image(cloudPosX1, cloudPosY1, anchor=NW, image=cloud_move1)
theCloud2 = canvas.create_image(cloudPosX2, cloudPosY2, anchor=NW, image=cloud_move2)
theSheep = canvas.create_image(sheepPosX, sheepPosY, anchor=NW, image=sheep[i])
message = canvas.create_text(320, 20, text='[I am the Queen in the blue sky!]',
                          font=('Courier',15))
if op == True:
    title = canvas.create_image(0, 0, anchor=NW, image=optitle)
    canvas.bind_all('<KeyPress-Return>', enter_game)#press Enter



canvas.bind_all('<KeyPress-Left>', move_sheep)
canvas.bind_all('<KeyPress-Right>', move_sheep)
canvas.bind_all('<KeyPress-Up>', takeback_sheep)
canvas.bind_all('<KeyPress-Down>', eat_grass)
canvas.bind_all('<KeyPress-space>', jump_sheep)
animation()

canvas.mainloop()
