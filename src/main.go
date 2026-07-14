package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

type Racer struct {
	Name  string
	Emoji string
	Pos   int
}

func main() {
	racers := []Racer{
		{"Молния", "🚀", 0},
		{"Босс", "🚗", 0},
		{"Спортсмен", "🚲", 0},
		{"Мудрец", "🐢", 0},
	}

	finishLine := 30
	var mu sync.Mutex
	winner := make(chan string, 1)

	var wg sync.WaitGroup

	for i := range racers {
		wg.Add(1)
		go func(r *Racer) {
			defer wg.Done()
			for {
				time.Sleep(time.Duration(rand.Intn(100)+20) * time.Millisecond)

				mu.Lock()
				if r.Pos >= finishLine {
					mu.Unlock()
					break
				}

				step := rand.Intn(3)
				r.Pos += step
				if r.Pos > finishLine {
					r.Pos = finishLine
				}

				if r.Pos == finishLine {
					select {
					case winner <- r.Emoji + " " + r.Name:
					default:
					}
				}
				mu.Unlock()
			}
		}(&racers[i])
	}

	ticker := time.NewTicker(100 * time.Millisecond)
	defer ticker.Stop()

	for {
		select {
		case w := <-winner:
			fmt.Print("\033[H\033[2J")
			fmt.Println("🏁 ЭМОДЗИ-ГОНКИ ЗАВЕРШЕНЫ 🏁")
			fmt.Println("==========================")
			fmt.Printf("\n🏆 ПОБЕДИТЕЛЬ: %s 🏆\n\n", w)
			return
		case <-ticker.C:
			fmt.Print("\033[H\033[2J")
			fmt.Println("🏁 ЭМОДЗИ-ГОНКИ 🏁")
			fmt.Println("==================")

			mu.Lock()
			for _, r := range racers {
				track := ""
				for i := 0; i < finishLine; i++ {
					if i == r.Pos {
						track += r.Emoji
					} else {
						track += "·"
					}
				}
				fmt.Printf("%-10s |%s| 🏁\n", r.Name, track)
			}
			mu.Unlock()
		}
	}
}
