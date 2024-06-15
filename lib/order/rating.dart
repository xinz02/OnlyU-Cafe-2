// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingWidget extends StatefulWidget {
  final DocumentSnapshot order;
  final Function(double foodRating, double serviceRating) onRatingSubmitted;

  const RatingWidget({
    Key? key,
    required this.order,
    required this.onRatingSubmitted,
  }) : super(key: key);

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  double _foodRating = 0.0;
  double _serviceRating = 0.0;

  void _submitRating() {
    widget.onRatingSubmitted(_foodRating, _serviceRating);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: contentBox(context),
      ),
    );
  }

  Widget contentBox(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(35),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, 10),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Rate Your Experience",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10), // Margin bottom for the title
              Text('Food Rating'),
              RatingBar.builder(
                initialRating: _foodRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 40.0,
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: _foodRating >= index + 1 ? Colors.amber : Colors.grey,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _foodRating = rating;
                  });
                },
              ),
              SizedBox(height: 20),
              Text('Service Rating'),
              RatingBar.builder(
                initialRating: _serviceRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 40.0,
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: _serviceRating >= index + 1 ? Colors.amber : Colors.grey,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _serviceRating = rating;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _submitRating();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 195, 133, 134), // Match background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Submit Rating',
                  style: TextStyle(color: Colors.white), // White text color
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
