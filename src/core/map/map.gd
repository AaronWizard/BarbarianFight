class_name Map
extends Node2D


var actors: ActorMap:
	get:
		return $ActorMap as ActorMap


var markers: MapMarkers:
	get:
		return $MapMarkers as MapMarkers
