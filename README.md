<!-- ABOUT -->
## Infinite Voronoi

<p align="center" width="100%">
    <img width="100%" src="/images/415064331.gif?raw=true">
</p>

This project is a tool coded in GDScript and C++ for use in a game I'm developing in Godot. The purpose of it is to seamlessly and infinitely generate interconnected polygons
within the viewport.

Voronoi diagrams are generated using Fortune's algorithm. The GDNative C++ bindings used to generate these diagrams is my own modified [fork](https://github.com/adinh254/godot_voronoi) of [rakai93's godot_voronoi](https://github.com/rakai93/godot_voronoi).

In order to generate an "infinite" world, the tool uses disk space and saves the generated polygons into world chunks in order to save memory.
The Voronoi generated chunks are pseudorandomly generated using a combination of Godot's seed randomizer and my own hash functions to be able to generate chunks that will always be in the same state when using the same seed.

The tool also has a feature that simulate caves by using percolation thresholds with a random walk algorithm. This feature is mainly based on [percolation theory](https://en.wikipedia.org/wiki/Percolation_theory).
You could also "smooth" out the shapes by increasing the Lloyd relaxation counts employed by the godot_voronoi bindings.

<!-- Random Walk & Percolation Examples -->
### Random Walk & Percolation Examples

<div style="display: inline-block;" max-width="50%">
    <img width="50%" src="/images/2765389554-1-0.5.gif?raw=true">
    <img width="50%" src="/images/2241024972-2-0.3.gif?raw=true">
    <img width="50%" src="/images/3702110211-3-0.7.gif?raw=true">
</div>

<p>
  Left Parameters: seed=2765389554; percolation_threshold=0.5; relaxation_count=1
  <br>
  Center Parameters: seed=3702110211; percolation_threshold=0.7; relaxation_count=3
  <br>
  Right Parameters: seed=2241024972; percolation_threshold=0.3; relaxation_count=2
</p>

### Built With
* [Godot](https://godotengine.org/)
* [Goost](https://goostengine.github.io/)
* [godot_voronoi](https://github.com/adinh254/godot_voronoi)
* [godot-cpp](https://github.com/godotengine/godot-cpp)

### Prerequisites

You will need the [Goost 1.2 binary](https://github.com/goostengine/goost/releases/tag/1.2-stable%2B3.4.1).

### Installation
Clone the repo
   ```sh
   git clone https://github.com/adinh254/procedural-voronoi.git
   ```
After cloning all you will need to do is run the Goost binary and import the project.godot file from your local folder where you cloned this repository.
To run a demo, simply press the play button near the top right when in the engine.

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` file for more information.

<!-- CONTACT -->
## Contact
Andrew Dinh - adinh254@gmail.com
